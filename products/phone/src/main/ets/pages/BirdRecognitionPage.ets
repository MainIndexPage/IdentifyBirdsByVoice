// entry/src/main/ets/pages/BirdRecognitionPage.ets
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import picker from '@ohos.file.picker'
import image from '@ohos.multimedia.image'

interface NavItem {
  name: string
  icon: Resource
  route: string
}

interface RecognizeResult {
  birdId: string
  nameZh: string
  nameLatin: string
  confidence: number
  poster: Resource
}

@Entry
@Component
struct BirdRecognitionPage {
  /* 底部导航 */
  @State currentNavIndex: number = 2   // 林声识羽/识别页高亮
  private navItems: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '识别', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社群', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ]

  private navClick(index: number) {
    if (index === this.currentNavIndex) return
    const target = this.navItems[index].route
    router.replaceUrl({ url: target })
    this.currentNavIndex = index
  }

  /* 识别状态 */
  @State selectedImage: Resource | null = null
  @State isRecognizing: boolean = false
  @State recognizeResult: RecognizeResult | null = null
  @State historyList: RecognizeResult[] = []

  build() {
    Column() {
      /* 顶部标题 */
      this.Header()

      /* 主内容区 */
      Scroll() {
        Column({ space: 16 }) {
          /* 图片选择/预览 */
          this.ImageSelector()

          /* 识别按钮 */
          if (this.selectedImage !== null && !this.isRecognizing && this.recognizeResult === null) {
            this.RecognizeButton()
          }

          /* 识别中 */
          if (this.isRecognizing) {
            this.RecognizingView()
          }

          /* 识别结果 */
          if (this.recognizeResult !== null) {
            this.ResultCard()
          }

          /* 历史记录 */
          if (this.historyList.length > 0) {
            this.HistorySection()
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      /* 底部导航 */
      this.BottomBar()
    }
    .width('100%')
    .height('100%')
  }

  /* -------------------- 顶部 -------------------- */
  @Builder
  Header() {
    Row() {
      // 返回按钮（新增）
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333')
        .onClick(() => {
          router.replaceUrl({ url: 'pages/BirdSoundRecognitionPage' })
        })

      Blank()

      Text('鸟类识别')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Blank()


    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }

  /* -------------------- 图片选择区 -------------------- */
  @Builder
  ImageSelector() {
    Column({ space: 12 }) {
      if (this.selectedImage === null) {
        /* 未选择图片：显示入口按钮 */
        Row({ space: 20 }) {
          this.SelectButton('拍照识别', $r('app.media.camera'), this.takePhoto)
          this.SelectButton('相册选择', $r('app.media.nav_encyclopedia'), this.pickFromAlbum)
        }
      } else {
        /* 已选择图片：预览 */
        Column({ space: 8 }) {
          Image(this.selectedImage)
            .width('100%')
            .height(280)
            .borderRadius(16)
            .objectFit(ImageFit.Cover)

          Row({ space: 12 }) {
            Button('重新选择')
              .fontSize(14)
              .fontColor('#666')
              .backgroundColor('#F0F0F0')
              .onClick(() => {
                this.selectedImage = null
                this.recognizeResult = null
              })

            if (this.recognizeResult !== null) {
              Button('查看详情')
                .fontSize(14)
                .fontColor('#FFF')
                .backgroundColor('#4CAF50')
                .onClick(() => {
                  // 跳转到图鉴详情
                  router.pushUrl({
                    url: 'pages/BirdDetailPage',
                    params: { birdId: this.recognizeResult?.birdId }
                  })
                })
            }
          }
        }
      }
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Builder
  SelectButton(text: string, icon: Resource, onClick: () => void) {
    Column({ space: 8 }) {
      Image(icon)
        .width(48)
        .height(48)
        .fillColor('#4CAF50')
      Text(text)
        .fontSize(14)
        .fontColor('#333')
    }
    .padding(24)
    .backgroundColor('#F5F5F5')
    .borderRadius(12)
    .onClick(onClick)
  }

  /* -------------------- 识别按钮 -------------------- */
  @Builder
  RecognizeButton() {
    Button('开始识别')
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .backgroundColor('#4CAF50')
      .borderRadius(24)
      .onClick(() => this.startRecognize())
  }

  /* -------------------- 识别中 -------------------- */
  @Builder
  RecognizingView() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#4CAF50')
      Text('正在识别鸟类特征...')
        .fontSize(14)
        .fontColor('#666')
    }
    .padding(32)
  }

  /* -------------------- 识别结果 -------------------- */
  @Builder
  ResultCard() {
    Column({ space: 12 }) {
      Text('识别结果')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      Row({ space: 16 }) {
        Image(this.recognizeResult!.poster)
          .width(80)
          .height(80)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)

        Column({ space: 6 }) {
          Text(this.recognizeResult!.nameZh)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text(this.recognizeResult!.nameLatin)
            .fontSize(12)
            .fontColor('#666')
          this.ConfidenceBadge(this.recognizeResult!.confidence)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F0FFF0')
      .borderRadius(12)
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Builder
  ConfidenceBadge(confidence: number) {
    Row() {
      Text(`置信度 ${(confidence * 100).toFixed(1)}%`)
        .fontSize(12)
        .fontColor('#FFF')
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(confidence > 0.8 ? '#4CAF50' : confidence > 0.5 ? '#FF9800' : '#F44336')
    .borderRadius(4)
  }

  /* -------------------- 历史记录 -------------------- */
  @Builder
  HistorySection() {
    Column({ space: 12 }) {
      Text('识别历史')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      List({ space: 8 }) {
        ForEach(this.historyList, (item: RecognizeResult, index: number) => {
          ListItem() {
            Row({ space: 12 }) {
              Image(item.poster)
                .width(56)
                .height(56)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)

              Column({ space: 4 }) {
                Text(item.nameZh)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                Text(item.nameLatin)
                  .fontSize(11)
                  .fontColor('#999')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(`${(item.confidence * 100).toFixed(0)}%`)
                .fontSize(12)
                .fontColor('#4CAF50')
            }
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/BirdDetailPage', params: { birdId: item.birdId } })
          })
        })
      }
      .height(200)
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  /* -------------------- 底部导航 -------------------- */
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

  /* -------------------- 业务逻辑 -------------------- */
  private takePhoto() {
    // 调用相机（实际需接入系统相机）
    promptAction.showToast({ message: '调用相机（待实现）' })
    // 模拟选择图片
    this.selectedImage = $r('app.media.Urocissa_erythroryncha')
  }

  private pickFromAlbum() {
    // 调用相册选择器
    let photoPicker = new picker.PhotoViewPicker()
    photoPicker.select({ maxSelectNumber: 1 }).then((result) => {
      if (result.photoUris.length > 0) {
        // 实际应加载选中图片
        this.selectedImage = $r('app.media.Platalea_minor')
      }
    }).catch(() => {
      promptAction.showToast({ message: '取消选择' })
    })
  }

  private startRecognize() {
    if (this.selectedImage === null) return

    this.isRecognizing = true
    this.recognizeResult = null

    // 模拟识别延迟
    setTimeout(() => {
      this.isRecognizing = false
      // 模拟识别结果
      this.recognizeResult = {
        birdId: '1',
        nameZh: '红嘴蓝鹊',
        nameLatin: 'Urocissa erythrorhyncha',
        confidence: 0.92,
        poster: $r('app.media.Urocissa_erythroryncha')
      }
      // 加入历史
      this.historyList.unshift(this.recognizeResult)
      promptAction.showToast({ message: '识别完成' })
    }, 2000)
  }
}