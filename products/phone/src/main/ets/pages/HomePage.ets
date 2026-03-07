import router from '@ohos.router';
import hilog from '@ohos.hilog';

interface NavItem {
  name: string;
  icon: Resource;
  route: string;
}

@Entry
@Component
export struct HomePage {
  @State currentNavIndex: number = 0;
  @State searchValue: string = '';

  private navItems: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '听音识鸟', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社群', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ];

  private navClick(index: number) {
    hilog.info(0x0000, 'HomePage', `Bottom nav clicked: ${index}`);
    if (index === this.currentNavIndex) return;
    const target = this.navItems[index].route;
    router.replaceUrl({ url: target });
    this.currentNavIndex = index;
  }

  private goToPage(pageRoute: string) {
    hilog.warn(0x0000, 'HomePage', `🚀 EXECUTING JUMP: ${pageRoute}`);
    try {
      router.replaceUrl({ url: pageRoute });
      hilog.info(0x0000, 'HomePage', `✅ replaceUrl called successfully`);

      const targetIndex = this.navItems.findIndex(item => item.route === pageRoute);
      if (targetIndex !== -1) {
        setTimeout(() => {
          this.currentNavIndex = targetIndex;
          hilog.info(0x0000, 'HomePage', `Nav index updated to: ${targetIndex}`);
        }, 100);
      }
    } catch (error) {
      hilog.error(0x0000, 'HomePage', `❌ Router error: ${error.message}`);
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

  build() {
    Stack() {
      // 第一层：背景图片
      Image($r('app.media.home_background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(20)
        .opacity(0.7)
        // 🔴 关键1：允许事件穿透到下层
        .hitTestBehavior(HitTestMode.Transparent)

      // 第二层：内容区域
      Column() {
        // 顶部标题
        Text('首页')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
          .margin({ top: 30, bottom: 10 })

        // 搜索框
        // 核心修改：移除 onSubmit 提交事件，新增 onClick 点击事件
        Search({ value: this.searchValue, placeholder: '搜索鸟类...' })
          .width('90%')
          .height(40)
          .margin({ bottom: 20 })
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          // 新增：点击整个搜索框区域触发跳转
          .onClick(() => {
            hilog.info(0x0000, 'HomePage', 'Search area clicked, jump to search page');
            this.goToPage('pages/BirdSearchPage');
          })
          // 保留 onChange 事件（可选：如果需要在搜索页回显输入的内容）
          .onChange((value: string) => {
            this.searchValue = value;
          });

        // 功能入口区域
        Column({ space: 16 }) {
          // 第一行：鸟类图鉴和听音识鸟
          Row() {
            // 左侧：鸟类图鉴
            Stack() {
              Image($r('app.media.card_bg_encyclopedia'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
                .blur(8)

              Column() {
                Text('鸟类图鉴')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textShadow({
                    radius: 2,
                    color: Color.Black,
                    offsetX: 2,
                    offsetY: 2
                  })
                  .margin({ bottom: 8 })
              }
              .justifyContent(FlexAlign.Center)
            }
            .width('45%')
            .height(100)
            // 🔴 关键2：显式设置可点击
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .onClick(() => {
              hilog.info(0x0000, 'HomePage', '📚 Encyclopedia card clicked');
              this.goToPage('pages/BirdGallery');
            })

            // 中间间距
            Blank().width('10%')

            // 右侧：听音识鸟
            Stack() {
              Image($r('app.media.card_bg_listen'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
                .blur(8)

              Column() {
                Text('听音识鸟')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textShadow({
                    radius: 2,
                    color: Color.Black,
                    offsetX: 2,
                    offsetY: 2
                  })
                  .margin({ bottom: 8 })
              }
              .justifyContent(FlexAlign.Center)
            }
            .width('45%')
            .height(100)
            // 🔴 关键2：显式设置可点击
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .onClick(() => {
              hilog.info(0x0000, 'HomePage', '🎵 Listen card clicked');
              this.goToPage('pages/BirdSoundRecognitionPage');
            })
          }
          .width('90%')

          // 保护鸟类入口
          Stack() {
            Image($r('app.media.card_bg_conservation'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(12)
              .blur(10)

            Column() {
              Text('保护鸟类')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .textShadow({
                  radius: 2,
                  color: Color.Black,
                  offsetX: 2,
                  offsetY: 2
                })
                .margin({ bottom: 12 })
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('90%')
          .height(120)
          // 🔴 关键2：显式设置可点击
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            hilog.info(0x0000, 'HomePage', '🛡️ Conservation card clicked');
            this.goToPage('pages/BirdConservationPage');
          })

          // 社群入口
          Stack() {
            Image($r('app.media.card_bg_community'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(12)
              .blur(10)

            Column() {
              Text('鸟类社群')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .textShadow({
                  radius: 2,
                  color: Color.Black,
                  offsetX: 2,
                  offsetY: 2
                })
                .margin({ bottom: 12 })
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('90%')
          .height(120)
          // 🔴 关键2：显式设置可点击
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            hilog.info(0x0000, 'HomePage', '👥 Community card clicked');
            this.goToPage('pages/BirdShare');
          })
          Row() {
            // 左侧：实时监控
            Stack() {
              Image($r('app.media.card_bg_monitor'))  // 需要添加对应的背景图资源
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
                .blur(8)

              Column() {
                Text('实时监控')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textShadow({
                    radius: 2,
                    color: Color.Black,
                    offsetX: 2,
                    offsetY: 2
                  })
                  .margin({ bottom: 8 })
              }
              .justifyContent(FlexAlign.Center)
            }
            .width('45%')
            .height(100)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .onClick(() => {
              hilog.info(0x0000, 'HomePage', '📹 Monitor card clicked');
              this.goToPage('pages/BirdMonitorPage');  // 根据实际页面路由修改
            })

            // 中间间距
            Blank().width('10%')

            // 右侧：公益
            Stack() {
              Image($r('app.media.card_bg_charity'))  // 需要添加对应的背景图资源
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
                .blur(8)

              Column() {
                Text('公益')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textShadow({
                    radius: 2,
                    color: Color.Black,
                    offsetX: 2,
                    offsetY: 2
                  })
                  .margin({ bottom: 8 })
              }
              .justifyContent(FlexAlign.Center)
            }
            .width('45%')
            .height(100)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .onClick(() => {
              hilog.info(0x0000, 'HomePage', '❤️ Charity card clicked');
              this.goToPage('pages/BirdPublicWelfarePage');  // 根据实际页面路由修改
            })
          }
          .width('90%')
        }

        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        // 🔴 关键3：内容区域也允许事件穿透（如果自身有透明背景）
        .hitTestBehavior(HitTestMode.Transparent)
      }
      .width('100%')
      .height('100%')

      // 第三层：底部导航栏
      Column() {
        Blank()
        this.BottomBar()
      }
      .width('100%')
      .height('100%')
      // 🔴 关键4：底部导航栏允许事件穿透（仅空白区域）
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}