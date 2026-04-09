import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { BirdBackendService, GenerateBirdImageResult } from '../services/BirdBackendService'

@Entry
@Component
struct BirdImageGenerationPage {
  @State birdName: string = ''
  @State habitat: string = ''
  @State sceneDescription: string = ''
  @State selectedStyle: string = '写实自然'
  @State isGenerating: boolean = false
  @State generatedImageUrl: string = ''
  @State generatedPrompt: string = ''
  @State requestId: string = ''
  @State errorMessage: string = ''

  private readonly styleOptions: string[] = ['写实自然', '科普海报', '清新插画', '水彩绘本']
  private readonly birdExamples: string[] = ['白鹭', '红嘴蓝鹊', '中华秋沙鸭', '朱鹮']

  private goBack() {
    try {
      router.back()
    } catch (_e) {
      router.replaceUrl({ url: 'pages/HomePage' })
    }
  }

  private buildPrompt(): string {
    const name: string = this.birdName.trim()
    const habitatText: string = this.habitat.trim().length > 0 ? this.habitat.trim() : '自然湿地环境'
    const sceneText: string = this.sceneDescription.trim().length > 0
      ? this.sceneDescription.trim()
      : '主体清晰，羽毛细节丰富，光线自然，画面干净'

    return `请生成一张${this.selectedStyle}风格的${name}鸟类图片，栖息环境为${habitatText}，${sceneText}，适合作为鸟类识别应用中的展示图片。`
  }

  private canGenerate(): boolean {
    return this.birdName.trim().length > 0
  }

  private getErrorMessage(error: Object): string {
    const maybeError = error as Error
    if (maybeError && typeof maybeError.message === 'string' && maybeError.message.length > 0) {
      return maybeError.message
    }
    const fallback: string = JSON.stringify(error)
    return fallback.length > 0 ? fallback : '图片生成失败，请检查后端或 API Key 配置'
  }

  private async generateImage() {
    if (this.isGenerating) {
      return
    }

    if (!this.canGenerate()) {
      promptAction.showToast({ message: '请先填写鸟类名称' })
      return
    }

    this.isGenerating = true
    this.errorMessage = ''
    try {
      const result: GenerateBirdImageResult = await BirdBackendService.generateBirdImage({
        prompt: this.buildPrompt(),
        negativePrompt: '模糊，低清晰度，畸形翅膀，多余肢体，错误文字，水印，杂乱背景',
        size: '1024*1024',
        n: 1,
        promptExtend: true,
        watermark: false
      })

      this.generatedImageUrl = result.imageUrl
      this.generatedPrompt = result.prompt || this.buildPrompt()
      this.requestId = result.requestId
      promptAction.showToast({ message: '鸟类图片生成成功' })
    } catch (e) {
      this.errorMessage = this.getErrorMessage(e)
      promptAction.showToast({ message: '图片生成失败' })
    } finally {
      this.isGenerating = false
    }
  }

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column({ space: 16 }) {
          this.HeroCard()
          this.FormCard()
          this.ResultCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => this.goBack())

      Text('鸟类文生图')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .fontColor('#333333')

      // Image($r('app.media.ic_camera'))
      //   .width(24)
      //   .height(24)
      //   .fillColor('#4CAF50')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  HeroCard() {
    Stack() {
      Image($r('app.media.news_owl'))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(16)

      Column({ space: 10 }) {
        Text('AI 鸟类绘图')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text('输入鸟类名称和画面描述，生成鸟类图片。')
          .fontSize(13)
          .fontColor('#F5F5F5')
          .maxLines(2)

        Row({ space: 8 }) {
          ForEach(this.birdExamples, (item: string) => {
            Text(item)
              .fontSize(11)
              .fontColor('#4CAF50')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .onClick(() => {
                this.birdName = item
              })
          })
        }
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(0, 0, 0, 0.30)')
      .borderRadius(16)
    }
    .width('100%')
    .height(160)
  }

  @Builder
  FormCard() {
    Column({ space: 14 }) {
      Text('生成参数')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      Column({ space: 8 }) {
        Text('鸟类名称')
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
        TextInput({ placeholder: '例如：白鹭、红嘴蓝鹊、朱鹮', text: this.birdName })
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.birdName = value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column({ space: 8 }) {
        Text('栖息环境')
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
        TextInput({ placeholder: '例如：湿地浅滩、林地枝头、湖边晨雾', text: this.habitat })
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.habitat = value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column({ space: 8 }) {
        Text('画面描述')
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
        TextArea({ placeholder: '例如：金色日出、羽毛细节清晰、主体居中、适合科普封面', text: this.sceneDescription })
          .width('100%')
          .height(110)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding(12)
          .onChange((value: string) => {
            this.sceneDescription = value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column({ space: 8 }) {
        Text('风格选择')
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.styleOptions, (item: string) => {
            Text(item)
              .fontSize(12)
              .fontColor(this.selectedStyle === item ? '#FFFFFF' : '#4CAF50')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.selectedStyle === item ? '#4CAF50' : '#E8F5E9')
              .borderRadius(16)
              .onClick(() => {
                this.selectedStyle = item
              })
          })
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Button(this.isGenerating ? '正在生成...' : '生成鸟类图片')
        .width('100%')
        .height(46)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor(this.canGenerate() ? '#4CAF50' : '#A5D6A7')
        .borderRadius(23)
        .onClick(() => this.generateImage())

      Text('图片尺寸为 1024×1024')
        .fontSize(11)
        .fontColor('#999999')
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Builder
  ResultCard() {
    Column({ space: 12 }) {
      Text('生成结果')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      if (this.isGenerating) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#4CAF50')
          Text('正在生成鸟类图片，请稍候...')
            .fontSize(13)
            .fontColor('#666666')
        }
        .width('100%')
        .height(220)
        .justifyContent(FlexAlign.Center)
      } else if (this.generatedImageUrl.length > 0) {
        Column({ space: 12 }) {
          Image(this.generatedImageUrl)
            .width('100%')
            .height(320)
            .borderRadius(16)
            .objectFit(ImageFit.Cover)
            .backgroundColor('#E8F5E9')

          if (this.generatedPrompt.length > 0) {
            Column({ space: 6 }) {
              Text('本次提示词')
                .fontSize(12)
                .fontColor('#4CAF50')
              Text(this.generatedPrompt)
                .fontSize(12)
                .fontColor('#666666')
                .lineHeight(18)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F7FBF7')
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)
          }

          if (this.requestId.length > 0) {
            Text('请求 ID：' + this.requestId)
              .fontSize(11)
              .fontColor('#999999')
              .width('100%')
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      } else if (this.errorMessage.length > 0) {
        Column({ space: 8 }) {
          Text('生成失败')
            .fontSize(16)
            .fontColor('#FF6B6B')
          Text(this.errorMessage)
            .fontSize(12)
            .fontColor('#666666')
            .lineHeight(18)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFF6F6')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)
      } else {
        Column({ space: 10 }) {
          Image($r('app.media.ic_camera'))
            .width(36)
            .height(36)
            .fillColor('#A5D6A7')
          Text('还没有生成图片')
            .fontSize(15)
            .fontColor('#666666')
          Text('填写上方参数后点击“生成鸟类图片”，结果会显示在这里。')
            .fontSize(12)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(220)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
