import { prompt } from '@kit.ArkUI'
import router from '@ohos.router'
import { BirdBackendService, LoginPayload, LoginResult } from '../services/BirdBackendService'

@Entry
@Component
struct BirdLogin {
  @State phone: string = ''
  @State password: string = ''
  @State errorTip: string = ''

  build() {
    Column() {
      Text('用户登录')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 120, bottom: 60 })
        .fontColor('#181818')

      TextInput({ placeholder: '请输入手机号' })
        .type(InputType.PhoneNumber)
        .width('100%')
        .height(56)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .onChange((v: string) => {
          this.phone = v
          this.errorTip = ''
        })

      TextInput({ placeholder: '请输入密码' })
        .type(InputType.Password)
        .width('100%')
        .height(56)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ top: 16 })
        .onChange((v: string) => {
          this.password = v
          this.errorTip = ''
        })

      if (this.errorTip.length > 0) {
        Text(this.errorTip)
          .fontSize(14)
          .fontColor('#F53F3F')
          .width('100%')
          .margin({ top: 8 })
      }

      Button('登录')
        .width('100%')
        .height(56)
        .margin({ top: 28 })
        .fontSize(18)
        .fontColor('#FFFFFF')
        .backgroundColor('#4CAF50')
        .borderRadius(8)
        .onClick(() => {
          this.handleLogin()
        })

      Text('没有账号？去注册')
        .fontSize(14)
        .fontColor('#007AFF')
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/BirdRegister' })
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 32, right: 32 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start)
  }

  private async handleLogin() {
    if (!/^1[3-9]\d{9}$/.test(this.phone)) {
      this.errorTip = '手机号格式错误'
      return
    }
    if (this.password.length < 6) {
      this.errorTip = '密码至少 6 位'
      return
    }

    try {
      const payload: LoginPayload = {
        phone: this.phone,
        password: this.password
      }
      const loginRes: LoginResult | null = await BirdBackendService.login(payload)

      if (loginRes === null) {
        this.errorTip = '登录失败，请检查账号密码'
        return
      }

      prompt.showToast({ message: '登录成功', duration: 1500 })
      router.replaceUrl({ url: 'pages/SplashPage' })
    } catch (_e) {
      this.errorTip = '登录失败，请检查网络或后端服务'
    }
  }
}
