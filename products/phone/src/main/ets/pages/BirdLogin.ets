import { prompt } from '@kit.ArkUI'
import router from '@ohos.router'
@Entry
@Component
struct LoginPage {
  // 定义状态变量：账号、密码、密码是否隐藏、表单错误提示
  @State account: string = ''
  @State password: string = ''
  @State isPwdHidden: boolean = true
  @State errorTip: string = ''

  build() {
    Column() {
      // 1. 页面标题
      Text('用户登录')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 120, bottom: 80 })
        .fontColor('#181818')

      // 2. 账号输入框
      Stack({ alignContent: Alignment.Start }) {
        Image($r('app.media.user')) // 可替换为自有账号图标
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .fillColor('#666666')

        TextInput({ placeholder: '请输入手机号/账号' })

          .width('100%')
          .height(56)
          .padding({ left: 56, right: 16 })
          .backgroundColor(Color.Transparent)
          .fontSize(16)
          .fontColor('#181818')
          .placeholderColor('#999999')

          .borderRadius(8)
          .onChange((value: string) => {
            this.account = value
            // 输入时清空错误提示
            this.errorTip = ''
          })
      }
      .backgroundColor('#F5F5F5')
      .margin({ bottom: 16 })

      // 3. 密码输入框
      Stack({ alignContent: Alignment.Start }) {
        Image($r('app.media.lock')) // 可替换为自有密码图标
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .fillColor('#666666')

        TextInput({ placeholder: '请输入登录密码' })
          .width('100%')
          .height(56)
          .padding({ left: 56, right: 56 })
          .fontSize(16)
          .fontColor('#181818')
          .placeholderColor('#999999')
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .type(this.isPwdHidden ? InputType.Password : InputType.Normal)
          .onChange((value: string) => {
            this.password = value
            // 输入时清空错误提示
            this.errorTip = ''
          })

        // 密码显示/隐藏切换按钮
        Button() {
          Image(this.isPwdHidden ? $r('app.media.lock') : $r('app.media.lock'))
            .width(24)
            .height(24)
            .fillColor('#666666')
        }
        .width(48)
        .height(48)
        .margin({ right: 8 })
        .backgroundColor('transparent')
        .onClick(() => {
          this.isPwdHidden = !this.isPwdHidden
        })
      }
      .margin({ bottom: 8 })

      // 4. 错误提示文本
      if (this.errorTip !== '') {
        Text(this.errorTip)
          .fontSize(14)
          .fontColor('#F53F3F')
          .margin({ left: 4, bottom: 24 })
          .textAlign(TextAlign.Start)
          .width('100%')
      }

      // 5. 登录按钮
      Button('登录')
        .width('100%')
        .height(56)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .backgroundColor('#4CAF50')
        .borderRadius(8)
        .onClick(() => {
          this.handleLogin()
        })

      // 6. 辅助操作（忘记密码/注册账号）
      Row() {
        Text('忘记密码？')
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            // 跳转忘记密码页面逻辑
            console.log('点击忘记密码')
          })

        Text('|')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ left: 16, right: 16 })

        Text('注册账号')
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/BirdRegister' })
          })
      }
      .margin({ top: 24 })
    }
    .width('100%')
    .padding({ left: 32, right: 32 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start)
    .height('100%')
  }

  /**
   * 登录处理函数（包含表单校验）
   */
  private handleLogin(): void {
    // 1. 账号非空校验
    if (this.account.trim() === '') {
      this.errorTip = '请输入账号/手机号'
      return
    }

    // 2. 密码非空校验
    if (this.password.trim() === '') {
      this.errorTip = '请输入登录密码'
      return
    }

    // 3. 密码长度校验（可选，可根据业务调整）
    if (this.password.length < 6) {
      this.errorTip = '密码长度不能少于6位'
      return
    }

    // 4. 校验通过，执行登录逻辑（此处为模拟，实际需对接接口）
    console.log(`账号：${this.account}，密码：${this.password}，开始登录`)
    this.errorTip = ''
    // 示例：模拟登录成功提示
    prompt.showToast({ message: '登录成功', duration: 2000 })
    // 后续可添加：跳转首页、存储用户信息等逻辑
    router.replaceUrl({
      url: 'pages/HomePage' // 关键：指定HomePage的页面路径，需与你的项目实际路径匹配
    })
  }
}