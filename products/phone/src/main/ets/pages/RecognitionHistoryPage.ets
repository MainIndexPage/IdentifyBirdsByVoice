import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { BirdBackendService, RecognitionHistoryItem, mapPosterResource } from '../services/BirdBackendService'

@Entry
@Component
struct RecognitionHistoryPage {
  @State private historyList: RecognitionHistoryItem[] = []
  @State private isLoading: boolean = false

  aboutToAppear(): void {
    this.loadRecognitionHistory()
  }

  private async loadRecognitionHistory(): Promise<void> {
    if (this.isLoading) {
      return
    }

    this.isLoading = true
    try {
      this.historyList = await BirdBackendService.fetchRecognitionHistory(100)
    } catch (_e) {
      this.historyList = []
      promptAction.showToast({ message: '识别记录加载失败，请检查后端服务。' })
    } finally {
      this.isLoading = false
    }
  }

  private goBack() {
    try {
      router.back()
    } catch (_e) {
      router.replaceUrl({ url: 'pages/BirdSoundRecognitionPage' })
    }
  }

  private openBirdDetail(item: RecognitionHistoryItem) {
    if (item.birdId <= 0) {
      promptAction.showToast({ message: '当前记录暂时无法跳转到鸟类详情。' })
      return
    }
    router.pushUrl({ url: 'pages/BirdDetail', params: { birdId: item.birdId } })
  }

  private formatTime(timestamp: number): string {
    if (timestamp <= 0) {
      return '未知时间'
    }
    const date: Date = new Date(timestamp)
    const year: number = date.getFullYear()
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0')
    const day: string = date.getDate().toString().padStart(2, '0')
    const hour: string = date.getHours().toString().padStart(2, '0')
    const minute: string = date.getMinutes().toString().padStart(2, '0')
    return `${year}-${month}-${day} ${hour}:${minute}`
  }

  private formatConfidence(confidence: number): string {
    return `${(confidence * 100).toFixed(2)}%`
  }

  private formatCoordinate(item: RecognitionHistoryItem): string {
    if (item.latitude === undefined || item.latitude === null ||
      item.longitude === undefined || item.longitude === null) {
      return '未记录经纬度'
    }
    return `${item.latitude.toFixed(4)}, ${item.longitude.toFixed(4)}`
  }

  private formatLocation(item: RecognitionHistoryItem): string {
    if (item.locationName.trim().length > 0) {
      return item.locationName
    }
    return this.formatCoordinate(item)
  }

  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => this.goBack())

      Text('识别记录')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .fontColor('#333333')

      Text('刷新')
        .fontSize(14)
        .fontColor('#4CAF50')
        .onClick(() => this.loadRecognitionHistory())
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  HistoryCard(item: RecognitionHistoryItem) {
    Row() {
      Image(mapPosterResource(item.birdPoster))
        .width(72)
        .height(72)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#E8F5E9')

      Column({ space: 6 }) {
        Text(item.birdNameZh.length > 0 ? item.birdNameZh : '未知鸟类')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(1)

        Text(item.birdNameLatin.length > 0 ? item.birdNameLatin : item.rawLabel)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(1)

        Text(`识别时间：${this.formatTime(item.recognizedAt)}`)
          .fontSize(12)
          .fontColor('#666666')

        Text(`置信度：${this.formatConfidence(item.confidence)}`)
          .fontSize(12)
          .fontColor('#4CAF50')

        Text(`位置：${this.formatLocation(item)}`)
          .fontSize(12)
          .fontColor('#666666')

        if (item.latitude !== undefined && item.latitude !== null &&
          item.longitude !== undefined && item.longitude !== null) {
          Text(`经纬度：${this.formatCoordinate(item)}`)
            .fontSize(11)
            .fontColor('#999999')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 12, right: 8 })

      Image($r('app.media.ic_arrow_right'))
        .width(18)
        .height(18)
        .fillColor('#BBBBBB')
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .onClick(() => this.openBirdDetail(item))
  }

  build() {
    Column() {
      this.TopBar()

      if (this.isLoading) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#4CAF50')
          Text('正在加载识别记录...')
            .fontSize(14)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.historyList.length === 0) {
        Column({ space: 12 }) {
          Image($r('app.media.ic_history'))
            .width(36)
            .height(36)
            .fillColor('#A5D6A7')
          Text('还没有识别记录')
            .fontSize(16)
            .fontColor('#333333')
          Text('完成一次鸟类识别后，这里会显示你的历史记录。')
            .fontSize(12)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 24, right: 24 })
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.historyList, (item: RecognitionHistoryItem) => {
            ListItem() {
              this.HistoryCard(item)
            }
          }, (item: RecognitionHistoryItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12, bottom: 20 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
