import router from '@ohos.router'
import { Bird } from './BirdModel'
import media from '@ohos.multimedia.media';
import { common } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';

/* 模拟图鉴数据库 */
const BIRD_GALLERY: Bird[] = [
  {
    id: '1',
    nameZh: '红嘴蓝鹊',
    nameLatin: 'Urocissa erythrorhyncha',
    family: '鸦科',
    habitat: '阔叶林',
    protection: '三有',
    poster: $r('app.media.Urocissa_erythroryncha'),
    call: $r('app.media.voice')
  },
  {
    id: '2',
    nameZh: '黑脸琵鹭',
    nameLatin: 'Platalea minor',
    family: '鹮科',
    habitat: '湿地',
    protection: '一级',
    poster: $r('app.media.Platalea_minor'),
    call: $r('app.media.voice')
  },
  {
    id: '3',
    nameZh: '普通翠鸟',
    nameLatin: 'Alcedo atthis',
    family: '翠鸟科',
    habitat: '湿地',
    protection: '三有',
    poster: $r('app.media.Alcedo_atthis'),
    call: $r('app.media.voice')
  },
  {
    id: '4',
    nameZh: '朱鹮',
    nameLatin: 'Nipponia nippon',
    family: '鹮科',
    habitat: '湿地',
    protection: '一级',
    poster: $r('app.media.Nipponia_nippon'),
    call: $r('app.media.voice')
  },
  {
    id: '5',
    nameZh: '中华秋沙鸭',
    nameLatin: 'Mergus squamatus',
    family: '鸭科',
    habitat: '河流',
    protection: '一级',
    poster: $r('app.media.Mergus_squamatus'),
    call: $r('app.media.voice')
  },
  {
    id: '6',
    nameZh: '黄腹角雉',
    nameLatin: 'Tragopan caboti',
    family: '雉科',
    habitat: '针阔混交林',
    protection: '一级',
    poster: $r('app.media.Tragopan_caboti'),
    call: $r('app.media.voice')
  },
  {
    id: '7',
    nameZh: '黑颈鹤',
    nameLatin: 'Grus nigricollis',
    family: '鹤科',
    habitat: '高原湿地',
    protection: '一级',
    poster: $r('app.media.Grus_nigricollis'),
    call: $r('app.media.voice')
  },
  {
    id: '8',
    nameZh: '褐马鸡',
    nameLatin: 'Crossoptilon mantchuricum',
    family: '雉科',
    habitat: '针叶林',
    protection: '一级',
    poster: $r('app.media.Crossoptilon_mantchuricum'),
    call: $r('app.media.voice')
  },
  {
    id: '9',
    nameZh: '白腹锦鸡',
    nameLatin: 'Chrysolophus amherstiae',
    family: '雉科',
    habitat: '阔叶林',
    protection: '二级',
    poster: $r('app.media.Chrysolophus_amherstiae'),
    call: $r('app.media.voice')
  },
  {
    id: '10',
    nameZh: '红腹锦鸡',
    nameLatin: 'Chrysolophus pictus',
    family: '雉科',
    habitat: '阔叶林',
    protection: '二级',
    poster: $r('app.media.Chrysolophus_pictus'),
    call: $r('app.media.voice')
  },
  {
    id: '11',
    nameZh: '东方白鹳',
    nameLatin: 'Ciconia boyciana',
    family: '鹳科',
    habitat: '湿地',
    protection: '一级',
    poster: $r('app.media.Ciconia_boyciana'),
    call: $r('app.media.voice')
  },
  {
    id: '12',
    nameZh: '大天鹅',
    nameLatin: 'Cygnus cygnus',
    family: '鸭科',
    habitat: '湖泊',
    protection: '二级',
    poster: $r('app.media.Cygnus_cygnus'),
    call: $r('app.media.voice')
  },
  {
    id: '13',
    nameZh: '鸳鸯',
    nameLatin: 'Aix galericulata',
    family: '鸭科',
    habitat: '森林溪流',
    protection: '二级',
    poster: $r('app.media.Aix_galericulata'),
    call: $r('app.media.voice')
  }
]
interface NavItem {
  name: string
  icon: Resource
  route: string
}
@Entry
@Component
struct BirdGalleryPage {
  @State list: Bird[] = BIRD_GALLERY
  @State filteredList: Bird[] = BIRD_GALLERY
  @State currentNavIndex: number = 1
  @State currentPlayingId: string = '';

  private avPlayer: media.AVPlayer | undefined = undefined;

  /* 筛选状态 */
  @State selectedFamily: string = '全部'
  @State selectedProtection: string = '全部'
  @State showFilterPanel: boolean = false

  /* 筛选选项 */
  private familyOptions: string[] = ['全部', '鸦科', '鹮科', '翠鸟科', '鸭科', '雉科', '鹤科', '鹳科']
  private protectionOptions: string[] = ['全部', '一级', '二级', '三有']
  private navList: NavItem[] = [
    { name:'首页', icon:$r('app.media.nav_home'), route:'pages/HomePage' },
    { name:'图鉴', icon:$r('app.media.nav_encyclopedia'), route:'pages/BirdGallery' },
    { name:'听音识鸟', icon:$r('app.media.nav_listen'), route:'pages/BirdSoundRecognitionPage' },
    { name:'社群', icon:$r('app.media.nav_community'), route:'pages/BirdShare' },
    { name:'我的', icon:$r('app.media.nav_profile'), route:'pages/ProfilePage' }
  ]
  /* 获取保护等级对应的颜色 */
  private getProtectionColor(text: string): string {
    if (text === '一级') return '#FF6B6B'
    if (text === '二级') return '#FFA726'
    if (text === '三有') return '#66BB6A'
    return '#4CAF50'
  }

  /* 应用筛选逻辑 */
  private applyFilter() {
    this.filteredList = this.list.filter((bird: Bird) => {
      const familyMatch = this.selectedFamily === '全部' || bird.family === this.selectedFamily
      const protectionMatch = this.selectedProtection === '全部' || bird.protection === this.selectedProtection
      return familyMatch && protectionMatch
    })
  }

  /* 重置筛选 */
  private resetFilter() {
    this.selectedFamily = '全部'
    this.selectedProtection = '全部'
    this.applyFilter()
  }

  /* ==================== 核心修复：音频播放逻辑 ==================== */
  private async playBirdCall(bird: Bird) {
    if (bird.id !== '1') {
      promptAction.showToast({ message: `${bird.nameZh}的叫声正在收录中...` });
      return;
    }

    // 1. 如果正在播放这只鸟，切换暂停/播放
    if (this.currentPlayingId === bird.id && this.avPlayer) {
      let currentState = this.avPlayer.state;
      if (currentState === 'playing') {
        await this.avPlayer.pause();
        promptAction.showToast({ message: '暂停' });
      } else if (currentState === 'paused') {
        await this.avPlayer.play();
        promptAction.showToast({ message: '继续播放' });
      }
      return;
    }

    // 2. 释放之前的播放器
    await this.cleanupPlayer();

    try {
      const context = getContext(this) as common.UIAbilityContext;

      // 3. 先获取文件描述符 (确保文件名正确)
      const fileName = 'Urocissa_erythrorynchaMp3.mp3';
      const fd = await context.resourceManager.getRawFileDescriptor(fileName);

      // 4. 创建播放器
      this.avPlayer = await media.createAVPlayer();

      // 5. 先绑定状态监听
      this.avPlayer.on('stateChange', async (state) => {
        console.info('AVPlayer State:', state);
        if (state === 'initialized') {
          await this.avPlayer?.prepare();
        } else if (state === 'prepared') {
          this.currentPlayingId = bird.id;
          await this.avPlayer?.play();
          promptAction.showToast({ message: '开始播放' });
        } else if (state === 'completed') {
          promptAction.showToast({ message: '播放完毕' });
          this.cleanupPlayer();
        }
      });

      this.avPlayer.on('error', (err) => {
        console.error('Playback Error:', JSON.stringify(err));
        promptAction.showToast({ message: '播放出错' });
        this.cleanupPlayer();
      });

      // 6. 直接设置音源 (关键步骤，不要等回调)
      console.info('Setting fdSrc...');
      this.avPlayer.fdSrc = fd;

    } catch (e) {
      console.error('Init Error:', JSON.stringify(e));
      promptAction.showToast({ message: '未找到音频文件，请检查 rawfile 目录' });
      this.cleanupPlayer();
    }
  }

  // 清理播放器资源
  private async cleanupPlayer() {
    this.currentPlayingId = '';
    if (this.avPlayer) {
      try {
        await this.avPlayer.release();
      } catch (e) {
        // 忽略释放错误
      }
      this.avPlayer = undefined;
    }
  }

  // 页面销毁时释放
  aboutToDisappear() {
    this.cleanupPlayer();
  }
  /* ==================== 音频逻辑结束 ==================== */

  private navClick(index: number) {
    if (index === this.currentNavIndex) return
    const target = this.navList[index].route
    router.replaceUrl({ url: target })
    this.currentNavIndex = index
  }

  build() {
    Column() {
      /* 顶部标题栏 */
      Row() {
        Text('鸟类图鉴')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        /* 筛选按钮 */
        Stack() {
          Text('筛选')
            .fontSize(14)
            .fontColor(this.showFilterPanel ? '#4CAF50' : '#666')
        }
        .width(40)
        .height(40)
        .onClick(() => {
          this.showFilterPanel = !this.showFilterPanel
        })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceBetween)

      /* 筛选面板 */
      if (this.showFilterPanel) {
        this.FilterPanel()
      }

      /* 结果统计 */
      Row() {
        Text(`共 ${this.filteredList.length} 种鸟类`)
          .fontSize(12)
          .fontColor('#999')

        if (this.selectedFamily !== '全部' || this.selectedProtection !== '全部') {
          Row({ space: 4 }) {
            if (this.selectedFamily !== '全部') {
              this.FilterTag(this.selectedFamily, () => {
                this.selectedFamily = '全部'
                this.applyFilter()
              })
            }
            if (this.selectedProtection !== '全部') {
              this.FilterTag(this.selectedProtection, () => {
                this.selectedProtection = '全部'
                this.applyFilter()
              })
            }
          }
          .margin({ left: 8 })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween)

      /* 图鉴列表 (已移除 ListItem 的 onClick) */
      List({ space: 12 }) {
        ForEach(this.filteredList, (bird: Bird) => {
          ListItem() {
            this.BirdRow(bird)
          }
        })
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .padding({ left: 16, right: 16 })

      this.BottomBar()
    }
    .width('100%')
    .height('100%')
  }

  /* 筛选面板 */
  @Builder
  FilterPanel() {
    Column({ space: 12 }) {
      /* 科属筛选 */
      Column({ space: 8 }) {
        Text('科属')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.familyOptions, (option: string) => {
            Text(option)
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.selectedFamily === option ? '#4CAF50' : '#F0F0F0')
              .fontColor(this.selectedFamily === option ? '#FFF' : '#666')
              .borderRadius(16)
              .margin(4)
              .onClick(() => {
                this.selectedFamily = option
                this.applyFilter()
              })
          })
        }
        .width('100%')
      }

      /* 保护等级筛选 */
      Column({ space: 8 }) {
        Text('保护等级')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.protectionOptions, (option: string) => {
            Text(option)
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.selectedProtection === option ? '#FF6B6B' : '#F0F0F0')
              .fontColor(this.selectedProtection === option ? '#FFF' : '#666')
              .borderRadius(16)
              .margin(4)
              .onClick(() => {
                this.selectedProtection = option
                this.applyFilter()
              })
          })
        }
        .width('100%')
      }

      /* 重置按钮 */
      Row() {
        Button('重置筛选')
          .fontSize(12)
          .height(32)
          .backgroundColor('#E0E0E0')
          .fontColor('#666')
          .onClick(() => {
            this.resetFilter()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#E0E0E0' })
  }

  /* 已选筛选标签（带删除） */
  @Builder
  FilterTag(text: string, onClose: () => void) {
    Row({ space: 4 }) {
      Text(text)
        .fontSize(10)
        .fontColor('#4CAF50')
      Text('×')
        .fontSize(12)
        .fontColor('#4CAF50')
        .onClick(() => onClose())
    }
    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
    .backgroundColor('#E8F5E9')
    .borderRadius(12)
  }

  /* ==================== 核心修复：单行 UI (点击事件分离) ==================== */
  @Builder
  BirdRow(bird: Bird) {
    Row({ space: 12 }) {
      // 左侧：图片+文字区域 (负责跳转)
      Row({ space: 12 }) {
        Image(bird.poster)
          .width(80)
          .height(80)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Column({ space: 4 }) {
          Text(bird.nameZh)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text(bird.nameLatin)
            .fontSize(12)
            .fontColor('#666')
          Row({ space: 6 }) {
            this.Tag(bird.family)
            this.Tag(bird.habitat)
            this.ProtectionTag(bird.protection)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .onClick(() => {
        // 点击左侧区域才跳转
        router.pushUrl({ url: 'pages/BirdDetail', params: { bird } })
      })

      // 右侧：喇叭区域 (负责播放)
      Stack() {
        Image($r('app.media.voice'))
          .width(24)
          .height(24)
          // 播放中改变颜色
          .fillColor(this.currentPlayingId === bird.id ? '#FF5722' : '#4CAF50')
      }
      .width(40)
      .height(40)
      .onClick(() => {
        // 点击右侧区域只播放
        this.playBirdCall(bird);
      })
    }
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /* 保护等级专用标签 */
  @Builder
  ProtectionTag(text: string) {
    Text(text)
      .fontSize(10)
      .fontColor('#FFF')
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      .backgroundColor(
        text === '一级' ? '#FF6B6B' :
          text === '二级' ? '#FFA726' :
            text === '三有' ? '#66BB6A' : '#4CAF50'
      )
      .borderRadius(4)
  }

  @Builder
  BottomBar() {
    Row() {
      ForEach(this.navList, (item: NavItem, idx: number) => {
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

  /* 通用标签 */
  @Builder
  Tag(text: string) {
    Text(text)
      .fontSize(10)
      .fontColor('#FFF')
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      .backgroundColor('#4CAF50')
      .borderRadius(4)
  }
}