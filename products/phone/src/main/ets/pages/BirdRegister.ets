import { prompt } from '@kit.ArkUI'
import router from '@ohos.router'
import { BirdBackendService, RegisterPayload } from '../services/BirdBackendService'

@Entry
@Component
struct BirdRegister {
  @State phone: string = ''
  @State password: string = ''
  @State confirmPwd: string = ''
  @State nickname: string = ''
  @State errorTip: string = ''

  build() {
    Column() {
      Text('用户注册')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 50 })
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

      TextInput({ placeholder: '请输入昵称（可选）' })
        .width('100%')
        .height(56)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ top: 16 })
        .onChange((v: string) => {
          this.nickname = v
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

      TextInput({ placeholder: '请再次输入密码' })
        .type(InputType.Password)
        .width('100%')
        .height(56)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ top: 16 })
        .onChange((v: string) => {
          this.confirmPwd = v
          this.errorTip = ''
        })

      if (this.errorTip.length > 0) {
        Text(this.errorTip)
          .fontSize(14)
          .fontColor('#F53F3F')
          .width('100%')
          .margin({ top: 8 })
      }

      Button('注册')
        .width('100%')
        .height(56)
        .margin({ top: 32 })
        .fontSize(18)
        .fontColor('#FFFFFF')
        .backgroundColor('#4CAF50')
        .borderRadius(8)
        .onClick(() => {
          this.handleRegister()
        })

      Text('已有账号？立即登录')
        .fontSize(14)
        .fontColor('#007AFF')
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/BirdLogin' })
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 32, right: 32 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start)
  }

  private async handleRegister() {
    if (!/^1[3-9]\d{9}$/.test(this.phone)) {
      this.errorTip = '手机号格式错误'
      return
    }
    if (this.password.length < 6) {
      this.errorTip = '密码至少 6 位'
      return
    }
    if (this.password !== this.confirmPwd) {
      this.errorTip = '两次密码不一致'
      return
    }

    try {
      const payload: RegisterPayload = {
        phone: this.phone,
        password: this.password,
        nickname: this.nickname
      }
      const ok: boolean = await BirdBackendService.register(payload)

      if (!ok) {
        this.errorTip = '注册失败，请稍后重试'
        return
      }

      prompt.showToast({ message: '注册成功，请登录', duration: 1800 })
      router.replaceUrl({ url: 'pages/BirdLogin' })
    } catch (_e) {
      this.errorTip = '注册失败，可能手机号已被占用'
    }
  }
}
