import { promptAction } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { abilityAccessCtrl, common, bundleManager } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { AudioCapture } from '../utils/AudioCapture';
import router from '@ohos.router';
import hilog from '@ohos.hilog';
import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';

// ================= 接口定义区 =================
interface NavItem {
  name: string;
  icon: Resource;
  route: string;
}

interface BirdResult {
  bird_name: string;
  confidence: number;
  label_id: number;
}

interface BackendResponse {
  code: number;
  msg: string;
  data: BirdResult[];
}

/**
 * 【新增】鸟类详细信息接口（预留数据库字段）
 */
interface BirdDetailInfo {
  standardChineseName: string;      // 标准中文名
  latinName: string;                // 拉丁学名
  genusExplanation: string;         // 属名解释
  englishCommonName: string;        // 英文俗名
  englishNameExplanation: string;   // 英文名解释
  speciesDescription: string;       // 物种介绍
  // 预留字段：图片URL、保护级别、分布区域等
  // imageUrl?: string;
  // conservationLevel?: string;
}

@Entry
@Component
struct BirdSoundRecognitionPage {
  // ================= 状态管理区 =================
  @State private isRecording: boolean = false;
  @State private isRecognizing: boolean = false;
  @State private recordedFilePath: string = '';
  @State private resultText: string = '请先录制鸟类声音或上传音频文件';
  @State private recordBtnText: string = '开始录音';
  @State private currentNavIndex: number = 2;

  // 【新增】控制是否显示详情卡片
  @State private showDetailCard: boolean = false;
  // 【新增】存储鸟类详细信息
  @State private birdDetail: BirdDetailInfo | null = null;

  // ================= 配置区 =================
  private navItems: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '听音识鸟', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社群', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ];

  private readonly SERVER_URL: string = 'http://10.0.2.2:8000/api/bird/recognize';

  // ================= 工具函数区 =================
  private stringToArrayBuffer(str: string): ArrayBuffer {
    const buffer: ArrayBuffer = new ArrayBuffer(str.length);
    const view: Uint8Array = new Uint8Array(buffer);
    for (let i: number = 0; i < str.length; i++) {
      view[i] = str.charCodeAt(i);
    }
    return buffer;
  }

  aboutToAppear(): void {
    console.info('BirdApp', '听音识鸟页面启动');
  }

  aboutToDisappear(): void {
    AudioCapture.release();
  }

  // ================= 权限与文件管理 =================
  private async checkPermission(): Promise<boolean> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      const bundleInfo: bundleManager.BundleInfo = bundleManager.getBundleInfoForSelfSync(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      const tokenId: number = bundleInfo.appInfo?.accessTokenId as number;

      const micPerm: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(tokenId, 'ohos.permission.MICROPHONE');
      if (micPerm === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        await atManager.requestPermissionsFromUser(context, ['ohos.permission.MICROPHONE', 'ohos.permission.INTERNET']);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  private createFile(): string {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const path: string = context.filesDir + '/bird_audio';
    if (!fileIo.accessSync(path)) {
      fileIo.mkdirSync(path);
    }
    const filePath: string = path + '/' + Date.now() + '.wav';
    const f: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.CREATE);
    fileIo.closeSync(f);
    return filePath;
  }

  // ================= 核心业务逻辑 =================
  private async handleClick() {
    if (this.isRecording) {
      this.isRecording = false;
      this.recordBtnText = '开始录音';
      await AudioCapture.stop();

      setTimeout(() => {
        if (this.recordedFilePath !== '' && fileIo.accessSync(this.recordedFilePath)) {
          const stat: fileIo.Stat = fileIo.statSync(this.recordedFilePath);
          console.info('BirdApp', '录音文件大小：', stat.size);
          if (stat.size > 100) {
            this.resultText = '录音完成，点击下方按钮识别';
          } else {
            this.resultText = '录音文件太小\n建议使用真机调试或上传文件';
          }
        }
      }, 300);

    } else {
      const hasPerm: boolean = await this.checkPermission();
      if (!hasPerm) {
        promptAction.showToast({ message: '请授予录音权限' });
        return;
      }

      this.recordedFilePath = this.createFile();
      this.isRecording = true;
      this.recordBtnText = '停止录音';
      this.resultText = '正在录音中...';
      // 开始录音前隐藏详情卡片
      this.showDetailCard = false;

      AudioCapture.start(this.recordedFilePath).catch((err: Error) => {
        console.error('BirdApp', '录音异常', err.message);
        if (this.isRecording) {
          this.isRecording = false;
          this.recordBtnText = '开始录音';
          this.resultText = '录音启动失败';
        }
      });
    }
  }

  /**
   * 【核心修改】识别成功后，加载鸟类详情
   */
  private async uploadAudioData(buffer: ArrayBuffer, fileName: string = 'bird.wav') {
    this.isRecognizing = true;
    this.resultText = '正在识别中...';
    this.showDetailCard = false; // 识别前隐藏旧卡片

    try {
      const boundary: string = '----Boundary' + Date.now();
      const headerStr: string = `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${fileName}"\r\nContent-Type: audio/wav\r\n\r\n`;
      const footerStr: string = `\r\n--${boundary}--\r\n`;

      const headerBuf: ArrayBuffer = this.stringToArrayBuffer(headerStr);
      const footerBuf: ArrayBuffer = this.stringToArrayBuffer(footerStr);

      const fullBody: Uint8Array = new Uint8Array(headerBuf.byteLength + buffer.byteLength + footerBuf.byteLength);
      fullBody.set(new Uint8Array(headerBuf), 0);
      fullBody.set(new Uint8Array(buffer), headerBuf.byteLength);
      fullBody.set(new Uint8Array(footerBuf), headerBuf.byteLength + buffer.byteLength);

      const httpRequest: http.HttpRequest = http.createHttp();
      const response = await httpRequest.request(this.SERVER_URL, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': `multipart/form-data; boundary=${boundary}` },
        extraData: fullBody.buffer,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      if (response.responseCode === 200 && response.result !== null) {
        const res: BackendResponse = JSON.parse(response.result as string) as BackendResponse;
        if (res.code === 200 && res.data && res.data.length > 0) {
          const topBird: BirdResult = res.data[0];
          this.resultText = `🎉 识别成功！\n置信度：${(topBird.confidence * 100).toFixed(2)}%`;

          // ================= 【关键新增】加载鸟类详情 =================
          await this.loadBirdDetail(topBird.label_id, topBird.bird_name);
          // ===========================================================

        } else {
          this.resultText = '未识别到有效鸟类';
          this.showDetailCard = false;
        }
      } else {
        this.resultText = '识别失败';
        this.showDetailCard = false;
        console.error('BirdApp', '服务器响应：', response.result);
      }
      httpRequest.destroy();
    } catch (e) {
      this.resultText = '网络连接失败';
      this.showDetailCard = false;
      console.error('BirdApp', '上传异常', JSON.stringify(e));
    } finally {
      this.isRecognizing = false;
    }
  }

  /**
   * 【新增】预留接口：从数据库加载鸟类详情
   * @param labelId 鸟类标签ID
   * @param birdName 鸟类名称（用于匹配）
   */
  private async loadBirdDetail(labelId: number, birdName: string): Promise<void> {
    console.info('BirdApp', `准备加载鸟类详情: ID=${labelId}, Name=${birdName}`);

    // TODO: 【预留数据库接口】
    // 未来接入数据库时，替换下面的模拟数据逻辑：
    // 1. 根据 labelId 或 birdName 查询本地 SQLite 数据库
    // 2. 或者调用后端接口 /api/bird/detail/{labelId}
    // 3. 将查询结果赋值给 this.birdDetail

    // ================= 【当前使用模拟数据】 =================
    this.birdDetail = {
      standardChineseName: '亚热带多拉霸鹟（也译尖翅伪霸鹟，为同物异名）',
      latinName: 'Pseudocolopteryx acutipennis',
      genusExplanation: '属名 Pseudocolopteryx 为多拉霸鹟属（也叫伪霸鹟属），种加词 acutipennis 意为 “尖翅的”',
      englishCommonName: 'Subtropical Doradito',
      englishNameExplanation: '直译即为 “亚热带多拉霸鹟”，是该物种的国际通用英文名称',
      speciesDescription: '该物种是雀形目霸鹟科的小型鸟类，原生分布于南美洲，多栖息在亚热带 / 热带的湿润灌丛、沼泽湿地周边。'
    };

    this.showDetailCard = true;
    // ========================================================
  }

  private async uploadRecordedFile() {
    if (this.recordedFilePath === '' || !fileIo.accessSync(this.recordedFilePath)) {
      promptAction.showToast({ message: '请先录制一段音频' });
      return;
    }

    const f: fileIo.File = fileIo.openSync(this.recordedFilePath, fileIo.OpenMode.READ_ONLY);
    const stat: fileIo.Stat = fileIo.statSync(f.fd);
    const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
    fileIo.readSync(f.fd, buffer);
    fileIo.closeSync(f);

    await this.uploadAudioData(buffer, 'recorded.wav');
  }

  private async pickAndUploadAudio() {
    try {
      const documentPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker();
      const options: picker.DocumentSelectOptions = {
        maxSelectNumber: 1
      };

      const uris: Array<string> = await documentPicker.select(options);

      if (uris && uris.length > 0) {
        const selectedUri: string = uris[0];
        console.info('BirdApp', '选择的URI: ' + selectedUri);

        let file: fileIo.File = fileIo.openSync(selectedUri, fileIo.OpenMode.READ_ONLY);
        let stat: fileIo.Stat = fileIo.statSync(file.fd);
        let buffer: ArrayBuffer = new ArrayBuffer(stat.size);
        fileIo.readSync(file.fd, buffer);
        fileIo.closeSync(file);

        promptAction.showToast({ message: '文件读取成功' });

        let fileName: string = 'uploaded.wav';
        const lastSlashIndex: number = selectedUri.lastIndexOf('/');
        if (lastSlashIndex !== -1) {
          fileName = selectedUri.substring(lastSlashIndex + 1);
        }

        await this.uploadAudioData(buffer, fileName);
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      if (err.code !== 20000001) {
        console.error('BirdApp', '选择文件失败: ' + JSON.stringify(err));
        promptAction.showToast({ message: '选择文件失败' });
      }
    }
  }

  // ================= 导航与UI构建 =================
  private navClick(index: number) {
    hilog.info(0x0000, 'BirdRecorderPage', `Nav clicked: ${index}`);
    if (index === this.currentNavIndex) return;
    const target: string = this.navItems[index].route;
    router.replaceUrl({ url: target });
    this.currentNavIndex = index;
  }

  @Builder
  BottomBar() {
    Row() {
      ForEach(this.navItems, (item: NavItem, idx: number) => {
        Column() {
          Image(item.icon)
            .width(24)
            .height(24)
            .fillColor(this.currentNavIndex === idx ? '#4CAF50' : '#999')
          Text(item.name)
            .fontSize(10)
            .fontColor(this.currentNavIndex === idx ? '#4CAF50' : '#999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => this.navClick(idx))
      })
    }
    .width('100%')
    .height(56)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#E0E0E0' })
  }

  /**
   * 【新增】鸟类详情卡片构建器
   */
  @Builder
  BirdDetailCard() {
    if (this.showDetailCard && this.birdDetail !== null) {
      Column({ space: 12 }) {
        // 标题行
        Row() {
          Text('📖 识别详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Blank()
        }
        .width('100%')

        // 【修复1】使用命名参数对象传参
        DetailItemBuilder({
          label: '标准中文名',
          content: this.birdDetail.standardChineseName,
          bgColor: '#E8F5E9'
        })

        DetailItemBuilder({
          label: '拉丁学名',
          content: this.birdDetail.latinName,
          bgColor: '#FFF3E0',
          isItalic: true
        })

        DetailItemBuilder({
          label: '名称释义',
          content: this.birdDetail.genusExplanation,
          bgColor: '#F5F5F5'
        })

        DetailItemBuilder({
          label: '英文俗名',
          content: this.birdDetail.englishCommonName,
          bgColor: '#E3F2FD'
        })

        DetailItemBuilder({
          label: '英文释义',
          content: this.birdDetail.englishNameExplanation,
          bgColor: '#F5F5F5'
        })

        DetailItemBuilder({
          label: '物种介绍',
          content: this.birdDetail.speciesDescription,
          bgColor: '#FCE4EC'
        })
      }
      .width('90%')
      .padding(16)
      .borderRadius(12)
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 10,
        color: '#1F000000',
        offsetX: 0,
        offsetY: 2
      })
      .margin({ top: 10, bottom: 10 })
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
    }
  }


  build() {
    Stack() {
      Scroll() { // 【新增】外层包裹 Scroll，防止详情卡片过长
        Column({ space: 20 }) {
          Column() {
            Text('听音识鸟')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ top: 40, bottom: 10 });

            Text(this.resultText)
              .fontSize(16)
              .padding(20)
              .width('90%')
              .borderRadius(10)
              .backgroundColor('#F5F5F5')
              .textAlign(TextAlign.Center);
          }

          // 【新增】鸟类详情卡片
          this.BirdDetailCard()

          if (this.isRecording || this.isRecognizing) {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#007DFF')
              .margin({ top: 20 });
          }

          Blank().height(10);

          Column({ space: 15 }) {
            // 大录音按钮
            Button(this.recordBtnText) {
              Stack() {
                Circle()
                  .width(280)
                  .height(280)
                  .fill(this.isRecording ? '#FFEBEE' : '#E8F5E9')
                  .opacity(0.5);
                Circle()
                  .width(240)
                  .height(240)
                  .fill(this.isRecording ? '#EF9A9A' : '#C8E6C9')
                  .opacity(0.7);
                Circle()
                  .width(200)
                  .height(200)
                  .fill(this.isRecording ? '#F44336' : '#4CAF50')
                  .shadow({
                    radius: 20,
                    color: this.isRecording ? '#F44336' : '#4CAF50',
                    offsetX: 0,
                    offsetY: 8
                  });
                Column() {
                  Image(this.isRecording ? $r('app.media.ic_stop') : $r('app.media.ic_microphone'))
                    .width(48)
                    .height(48)
                    .fillColor('#FFFFFF')
                    .margin({ bottom: 8 })
                  Text(this.recordBtnText)
                    .fontSize(16)
                    .fontColor('#FFFFFF');
                }
              }
            }
            .width(280)
            .height(280)
            .type(ButtonType.Normal)
            .backgroundColor('#00000000')
            .enabled(!this.isRecognizing)
            .onClick(() => {
              this.handleClick();
            });

            Button('识别刚才的录音')
              .width('80%')
              .height(50)
              .backgroundColor('#007DFF')
              .enabled(!this.isRecording && !this.isRecognizing && this.recordedFilePath !== '')
              .onClick(() => {
                this.uploadRecordedFile();
              });

            Row() {
              Column() {
                Image($r('app.media.ic_history'))
                  .width(24)
                  .height(24)
                  .fillColor('#666666')
                  .margin({ bottom: 4 });
                Text('识别历史')
                  .fontSize(12)
                  .fontColor('#666666');
              }
              .layoutWeight(1)
              .onClick(() => {
                promptAction.showToast({ message: '功能开发中' });
              });

              Column() {
                Image($r('app.media.ic_public_folder'))
                  .width(24)
                  .height(24)
                  .fillColor('#666666')
                  .margin({ bottom: 4 });
                Text('上传音频')
                  .fontSize(12)
                  .fontColor('#666666');
              }
              .layoutWeight(1)
              .enabled(!this.isRecognizing)
              .onClick(() => {
                this.pickAndUploadAudio();
              });

              Column() {
                Image($r('app.media.camera'))
                  .width(24)
                  .height(24)
                  .fillColor('#666666')
                  .margin({ bottom: 4 });
                Text('图片识鸟')
                  .fontSize(12)
                  .fontColor('#666666');
              }
              .layoutWeight(1)
              .onClick(() => {
                promptAction.showToast({ message: '功能开发中' });
              });
            }
            .width('100%')
            .margin({ top: 20, bottom: 20 });
          }
          .padding({ bottom: 20, top: 10 });
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off) // 隐藏滚动条

      Column() {
        Blank()
        this.BottomBar()
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 【辅助组件】详情项构建器
 */
@Component
struct DetailItemBuilder {
  @Prop label: string = '';
  @Prop content: string = '';
  @Prop bgColor: ResourceColor = '#F5F5F5';
  @Prop isItalic: boolean = false;

  build() {
    Column() {
      Row() {
        Text(this.label)
          .fontSize(12)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')
      .margin({ bottom: 4 })

      Text(this.content)
        .fontSize(14)
        .fontColor('#333333')
        .fontStyle(this.isItalic ? FontStyle.Italic : FontStyle.Normal)
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .padding(12)
    .borderRadius(8)
    .backgroundColor(this.bgColor)
  }
}