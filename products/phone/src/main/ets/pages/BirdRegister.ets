import { prompt } from '@kit.ArkUI'
import router from '@ohos.router'
@Entry
@Component
struct BirdRegister {
  @State phone: string = ''
  @State smsCode: string = ''
  @State password: string = ''
  @State confirmPwd: string = ''
  @State isPwdHidden: boolean = true
  @State isConfirmHidden: boolean = true
  @State errorTip: string = ''
  @State countDown: number = 0        // 倒计时剩余秒数
  private timer: number = -1          // setInterval 句柄

  build() {
    Column() {
      // 1. 标题
      Text('用户注册')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 60 })
        .fontColor('#181818')

      // 2. 手机号
      TextInput({ placeholder: '请输入手机号' })
        .type(InputType.PhoneNumber)
        .width('100%').height(56)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .onChange((v) => {
          this.phone = v; this.errorTip = ''
        })

      // 3. 验证码一行
      Row() {
        TextInput({ placeholder: '请输入验证码' })
          .type(InputType.Number)
          .layoutWeight(1)
          .height(56)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .onChange((v) => {
            this.smsCode = v; this.errorTip = ''
          })

        Button(this.countDown > 0 ? `${this.countDown}s` : '获取验证码')
          .width(110).height(56)
          .margin({ left: 12 })
          .enabled(this.countDown === 0 && this.phone.length === 11)
          .backgroundColor('#4CAF50')
          .onClick(() => this.getSmsCode())
      }.width('100%').margin({ top: 16 })

      // 4. 密码
      TextInput({ placeholder: '请输入密码' })
        .type(InputType.Password)          // 始终密文
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })  // 左右对称，无图标占位
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .fontSize(16)
        .fontColor('#181818')
        .placeholderColor('#999999')
        .onChange((v) => {
          this.password = v; this.errorTip = ''
        })
        .margin({ top: 16 })

      // 2. 确认密码（同上，再复制一份）
      TextInput({ placeholder: '请再次输入密码' })
        .type(InputType.Password)
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .fontSize(16)
        .fontColor('#181818')
        .placeholderColor('#999999')
        .onChange((v) => {
          this.confirmPwd = v; this.errorTip = ''
        })
        .margin({ top: 16 })

      // 6. 错误提示
      if (this.errorTip) {
        Text(this.errorTip)
          .fontSize(14).fontColor('#F53F3F')
          .width('100%').margin({ top: 8 })
      }

      // 7. 注册按钮
      Button('注册')
        .width('100%').height(56)
        .margin({ top: 32 })
        .fontSize(18).fontColor('#FFFFFF')
        .backgroundColor('#4CAF50')
        .borderRadius(8)
        .onClick(() => this.handleRegister())

      // 8. 返回登录
      Text('已有账号？立即登录')
        .fontSize(14).fontColor('#007AFF')
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/BirdLogin' })
        })
    }
    .width('100%').height('100%')
    .padding({ left: 32, right: 32 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start)
  }

  // 获取验证码
  private getSmsCode(): void {
    if (!/^1[3-9]\d{9}$/.test(this.phone)) {
      this.errorTip = '请输入正确手机号'
      return
    }
    // 这里调后台接口发验证码
    prompt.showToast({ message: '验证码已发送' })
    this.countDown = 60
    this.timer = setInterval(() => {
      if (this.countDown > 0) {
        this.countDown--
      } else {
        clearInterval(this.timer)
      }
    }, 1000)
  }

  // 注册
  private handleRegister(): void {
    if (!/^1[3-9]\d{9}$/.test(this.phone)) {
      this.errorTip = '手机号格式错误'; return
    }
    if (!/^\d{6}$/.test(this.smsCode)) {
      this.errorTip = '验证码为 6 位数字'; return
    }
    if (this.password.length < 6) {
      this.errorTip = '密码至少 6 位'; return
    }
    if (this.password !== this.confirmPwd) {
      this.errorTip = '两次密码不一致'; return
    }
    // 调后台注册
    prompt.showToast({
      message: '注册成功',
      duration: 2000          // 2 秒后消失
    })
    // 后续：回登录页 or 直接登录
    setTimeout(() => {
      router.pushUrl({
        url: 'pages/SplashPage'
      })
    }, 2000)
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }
}