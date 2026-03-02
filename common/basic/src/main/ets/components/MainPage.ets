// getWidthBP(windowStage: window.WindowStage) {
//   let deviceType = 'xs'
//   // 1.获取断点
//   let widthBP = windowStage.getMainWindowSync().getUIContext().getWindowWidthBreakpoint()
//   // 2.根据断点类型区分设备类型
//   if (widthBP === WidthBreakpoint.WIDTH_XS) {
//     deviceType = 'xs'
//   } else if (widthBP === WidthBreakpoint.WIDTH_SM) {
//     deviceType = 'sm'
//   } else if (widthBP === WidthBreakpoint.WIDTH_MD) {
//     deviceType = 'md'
//   } else if (widthBP === WidthBreakpoint.WIDTH_LG) {
//     deviceType = 'lg'
//   } else if (widthBP === WidthBreakpoint.WIDTH_XL) {
//     deviceType = 'xl'
//   }
//   //   3.将断点类型存入appStorage
//   AppStorage.setOrCreate('widthBP', deviceType)
// }
// onWindowStageCreate(windowStage: window.WindowStage): void {
//   // Main window is created, set main page for this ability
//   hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
//
//   windowStage.loadContent('pages/Index', (err) => {
//   if (err.code) {
//   hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
//   return;
// }
// hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
// try {
//   this.getWidthBP(windowStage)
//   // 监听设备尺寸变化调用
//   windowStage.getMainWindowSync().on('windowSizeChange', () => {
//     this.getWidthBP(windowStage)
//   })
// } catch (error) {
//   // TODO: Implement error handling.
// }
// });
// }


@Component
export struct MainPage {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message = 'Welcome';
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
