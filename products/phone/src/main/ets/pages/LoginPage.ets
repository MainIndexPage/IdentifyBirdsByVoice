// LoginPage.ets
import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  private phoneNumber: string = '';
  private verifyCode: string = '';
  private isAgreed: boolean = false;

  build() {
    Column() {
      // 顶部 slogan
      Text('林音识羽')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#555')
        .margin({ top: 60, bottom: 40 })

      // 手机号输入框
      TextInput({
        placeholder: '请输入手机号',
        text: this.phoneNumber,
        // onChange: (value) => {
        //   this.phoneNumber = value;
        // }
      })
        .type(InputType.PhoneNumber)
        .width('85%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .borderRadius(8)
        .backgroundColor('#f9f9f9')
        .margin({ bottom: 16 })

      // 验证码输入 + 获取按钮
      Row() {
        TextInput({
          placeholder: '验证码',
          text: this.verifyCode,
          // onChange: (value) => {
          //   this.verifyCode = value;
          // }
        })
          .type(InputType.Number)
          .width('65%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
          .backgroundColor('#f9f9f9')

        Button('获取验证码')
          .width('30%')
          .height(50)
          .fontSize(14)
          .fontColor('#fff')
          .backgroundColor('#4A90E2')
          .borderRadius(8)
          .margin({ left: 12 })
      }
      .width('85%')
      .margin({ bottom: 24 })

      // 登录按钮
      Button('登录')
        .width('85%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#fff')
        .backgroundColor('#5CB85C')
        .borderRadius(25)
        .margin({ bottom: 20 })
        .onClick(() => {
          // TODO: 实现登录逻辑
          console.log('Login with phone:', this.phoneNumber, 'code:', this.verifyCode);
        })

      // 忘记密码
      Text('忘记密码？')
        .fontSize(14)
        .fontColor('#888')
        .onClick(() => {
          // 跳转找回密码页面
          router.pushUrl({ url: 'pages/ForgetPassword' });
        })
        .margin({ bottom: 30 })

      // 分割线
      Row() {
        Divider()
          .strokeWidth(1)
          .color('#ddd')
          .width('35%')
        Text('或')
          .fontSize(14)
          .fontColor('#999')
          .margin({ left: 8, right: 8 })
        Divider()
          .strokeWidth(1)
          .color('#ddd')
          .width('35%')
      }
      .width('85%')
      .margin({ bottom: 24 })

      // 微信快捷登录
      Button('微信登录')
        .width('85%')
        .height(50)
        .fontSize(16)
        .fontColor('#fff')
        .backgroundColor('#07C160')
        .borderRadius(25)
        .onClick(() => {
          // TODO: 调用微信 SDK
          console.log('WeChat login');
        })
        .margin({ bottom: 20 })

      // 注册入口
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#888')
        Text('立即注册')
          .fontSize(14)
          .fontColor('#4A90E2')
          .onClick(() => {
            router.pushUrl({ url: 'pages/Register' });
          })
      }
      .margin({ bottom: 40 })

      // 底部鸟类剪影装饰（使用 Image 或自定义 SVG）
      // 假设你有一个 bird_silhouette.png 放在 resources/base/media/
      // Image($r('app.media.bird_silhouette'))
      //   .width(200)
      //   .height(80)
      //   .objectFit(ImageFit.Contain)
      //   .opacity(0.15)
      //   .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff') // 浅色背景
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}