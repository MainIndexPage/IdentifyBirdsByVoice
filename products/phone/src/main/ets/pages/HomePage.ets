import router from '@ohos.router'
import hilog from '@ohos.hilog'

interface NavItem {
  name: string
  icon: Resource
  route: string
}

@Entry
@Component
export struct HomePage {
  @State currentNavIndex: number = 0
  @State searchValue: string = ''

  private navItems: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '林声识羽', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社区', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ]

  private navClick(index: number) {
    hilog.info(0x0000, 'HomePage', `Bottom nav clicked: ${index}`)
    if (index === this.currentNavIndex) {
      return
    }
    const target = this.navItems[index].route
    router.replaceUrl({ url: target })
    this.currentNavIndex = index
  }

  private openPage(pageRoute: string, usePush: boolean = false) {
    try {
      if (usePush) {
        router.pushUrl({ url: pageRoute })
        return
      }

      router.replaceUrl({ url: pageRoute })
      const targetIndex = this.navItems.findIndex((item: NavItem) => item.route === pageRoute)
      if (targetIndex >= 0) {
        this.currentNavIndex = targetIndex
      }
    } catch (error) {
      hilog.error(0x0000, 'HomePage', `Router error: ${JSON.stringify(error)}`)
    }
  }

  @Builder
  BottomBar() {
    Row() {
      ForEach(this.navItems, (item: NavItem, idx: number) => {
        Column() {
          Image(item.icon)
            .width(24)
            .height(24)
            .fillColor(this.currentNavIndex === idx ? '#4CAF50' : '#999999')

          Text(item.name)
            .fontSize(10)
            .fontColor(this.currentNavIndex === idx ? '#4CAF50' : '#999999')
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

  build() {
    Stack() {
      Image($r('app.media.home_background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(20)
        .opacity(0.7)
        .hitTestBehavior(HitTestMode.Transparent)

      Column() {
        Scroll() {
          Column({ space: 16 }) {
            Text('林声识羽')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')
              .margin({ top: 30, bottom: 6 })

            Search({ value: this.searchValue, placeholder: '搜索鸟类...' })
              .width('100%')
              .height(40)
              .backgroundColor('#FFFFFF')
              .borderRadius(20)
              .onClick(() => {
                this.openPage('pages/BirdSearchPage')
              })
              .onChange((value: string) => {
                this.searchValue = value
              })

            Row() {
              Stack() {
                Image($r('app.media.card_bg_encyclopedia'))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(14)
                  .blur(8)

                Column({ space: 8 }) {
                  Text('鸟类图鉴')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .textShadow({
                      radius: 3,
                      color: '#66000000',
                      offsetX: 0,
                      offsetY: 1
                    })
                  Text('查看数据库中的鸟类资料')
                    .fontSize(12)
                    .fontColor('#F2F2F2')
                    .textShadow({
                      radius: 3,
                      color: '#66000000',
                      offsetX: 0,
                      offsetY: 1
                    })
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .width('45%')
              .height(108)
              .clickEffect({ level: ClickEffectLevel.MIDDLE })
              .onClick(() => this.openPage('pages/BirdGallery'))

              Blank().width('10%')

              Stack() {
                Image($r('app.media.card_bg_listen'))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(14)
                  .blur(8)

                Column({ space: 8 }) {
                  Text('林声识羽')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .textShadow({
                      radius: 3,
                      color: '#66000000',
                      offsetX: 0,
                      offsetY: 1
                    })
                  Text('识别声音并匹配图鉴内容')
                    .fontSize(12)
                    .fontColor('#F2F2F2')
                    .textShadow({
                      radius: 3,
                      color: '#66000000',
                      offsetX: 0,
                      offsetY: 1
                    })
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .width('45%')
              .height(108)
              .clickEffect({ level: ClickEffectLevel.MIDDLE })
              .onClick(() => this.openPage('pages/BirdSoundRecognitionPage'))
            }
            .width('100%')

            Stack() {
              Image($r('app.media.card_bg_conservation'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(14)
                .blur(8)

              Column({ space: 8 }) {
                Text('保护鸟类')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textShadow({
                    radius: 3,
                    color: '#66000000',
                    offsetX: 0,
                    offsetY: 1
                  })
                Text('了解保护知识与生态倡议')
                  .fontSize(12)
                  .fontColor('#F4F4F4')
                  .textShadow({
                    radius: 3,
                    color: '#66000000',
                    offsetX: 0,
                    offsetY: 1
                  })
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .height(120)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .onClick(() => this.openPage('pages/BirdConservationPage'))

            Stack() {
              Image($r('app.media.card_bg_community'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(14)
                .blur(8)

              Column({ space: 8 }) {
                Text('鸟类社区')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textShadow({
                    radius: 3,
                    color: '#66000000',
                    offsetX: 0,
                    offsetY: 1
                  })
                Text('分享观鸟记录与识别结果')
                  .fontSize(12)
                  .fontColor('#F4F4F4')
                  .textShadow({
                    radius: 3,
                    color: '#66000000',
                    offsetX: 0,
                    offsetY: 1
                  })
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .height(120)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .onClick(() => this.openPage('pages/BirdShare'))

            Row() {
              Stack() {
                Image($r('app.media.card_bg_monitor'))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(14)
                  .blur(8)

                Column({ space: 8 }) {
                  Text('实时监测')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .textShadow({
                      radius: 3,
                      color: '#66000000',
                      offsetX: 0,
                      offsetY: 1
                    })
                  Text('查看观测信息')
                    .fontSize(12)
                    .fontColor('#F2F2F2')
                    .textShadow({
                      radius: 3,
                      color: '#66000000',
                      offsetX: 0,
                      offsetY: 1
                    })
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .width('45%')
              .height(108)
              .clickEffect({ level: ClickEffectLevel.MIDDLE })
              .onClick(() => this.openPage('pages/BirdMonitorPage'))

              Blank().width('10%')

              Stack() {
                Image($r('app.media.card_bg_charity'))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(14)
                  .blur(8)

                Column({ space: 8 }) {
                  Text('公益活动')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .textShadow({
                      radius: 3,
                      color: '#66000000',
                      offsetX: 0,
                      offsetY: 1
                    })
                  Text('参与志愿与公益项目')
                    .fontSize(12)
                    .fontColor('#F2F2F2')
                    .textShadow({
                      radius: 3,
                      color: '#66000000',
                      offsetX: 0,
                      offsetY: 1
                    })
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .width('45%')
              .height(108)
              .clickEffect({ level: ClickEffectLevel.MIDDLE })
              .onClick(() => this.openPage('pages/BirdPublicWelfarePage'))
            }
            .width('100%')

            Stack() {
              Image($r('app.media.news_owl'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(14)
                .blur(4)

              Column({ space: 8 }) {
                Text('AI 鸟类文生图')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textShadow({
                    radius: 4,
                    color: '#80000000',
                    offsetX: 0,
                    offsetY: 1
                  })
                Text('输入鸟类名称和画面描述，生成对应鸟类')
                  .fontSize(12)
                  .fontColor('#F4F4F4')
                  .textShadow({
                    radius: 4,
                    color: '#80000000',
                    offsetX: 0,
                    offsetY: 1
                  })
              }
              .width('100%')
              .height('100%')
              .padding(16)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0, 0, 0, 0.25)')
              .borderRadius(14)
            }
            .width('100%')
            .height(128)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .onClick(() => this.openPage('pages/BirdImageGenerationPage', true))

            Stack() {
              Image($r('app.media.news_discovery'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(14)
                .blur(4)

              Column({ space: 8 }) {
                Text('识别记录地图')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textShadow({
                    radius: 4,
                    color: '#80000000',
                    offsetX: 0,
                    offsetY: 1
                  })
                Text('在世界视图中查看每次识别留下的位置标记与鸟类记录')
                  .fontSize(12)
                  .fontColor('#F4F4F4')
                  .textShadow({
                    radius: 4,
                    color: '#80000000',
                    offsetX: 0,
                    offsetY: 1
                  })
              }
              .width('100%')
              .height('100%')
              .padding(16)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0, 0, 0, 0.28)')
              .borderRadius(14)
            }
            .width('100%')
            .height(128)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .onClick(() => this.openPage('pages/RecognitionMapPage', true))
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        this.BottomBar()
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
