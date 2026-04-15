import { router } from '@kit.ArkUI'
@Entry
@Component
struct SplashPage {
  @State opacityValue: number = 1
  @State scaleValue: number = 1

  aboutToAppear() {
    // 2秒后跳转到首页
    setTimeout(() => {
      this.animateAndNavigate()
    }, 2000)
  }

  animateAndNavigate() {
    // 淡出动画
    animateTo({
      duration: 500,
      curve: Curve.EaseInOut,
      onFinish: () => {
        // 动画完成后跳转
        router.replaceUrl({
          url: 'pages/HomePage'  // 你的首页
        })
      }
    }, () => {
      this.opacityValue = 0
      this.scaleValue = 1.1  // 轻微放大效果
    })
  }

  build() {
    Stack() {
      // 背景图或颜色
      Image($r('app.media.White_bc'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // Logo和文字
      Column() {
        Image($r('app.media.logo'))
          .width(120)
          .height(120)
          .margin({ bottom: 20 })

        Text('林声识羽')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('V 1.0.0')
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.7)')
          .margin({ top: 10 })
      }
      .scale({ x: this.scaleValue, y: this.scaleValue })

      // 底部版权
      Text('© 2024 IdentifyBirdsByVoice sspu')
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.5)')
        .position({ x: 0, y: '90%' })
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .opacity(this.opacityValue)
    .backgroundColor('#FF6B6B') // 品牌色
  }
}