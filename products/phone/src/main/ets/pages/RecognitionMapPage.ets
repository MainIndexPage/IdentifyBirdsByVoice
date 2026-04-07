import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { BirdBackendService, RecognitionHistoryItem, mapPosterResource } from '../services/BirdBackendService'

interface RecognitionMapMarker {
  id: string
  birdId: number
  birdNameZh: string
  birdNameLatin: string
  birdPoster: string
  locationName: string
  confidence: number
  recognizedAt: number
  latitude: number
  longitude: number
}

@Entry
@Component
struct RecognitionMapPage {
  private readonly MAP_BASE_WIDTH: number = 340
  private readonly MAP_BASE_HEIGHT: number = 178
  private readonly MAP_FRAME_LEFT_RATIO: number = 142 / 4655
  private readonly MAP_FRAME_RIGHT_RATIO: number = 142 / 4655
  private readonly MAP_FRAME_TOP_RATIO: number = 142 / 2444
  private readonly MAP_FRAME_BOTTOM_RATIO: number = 143 / 2444
  private readonly MAP_LEFT_BOUNDARY_LONGITUDE: number = -28.5
  private readonly MAP_SCALE_MIN: number = 1
  private readonly MAP_SCALE_MAX: number = 8
  private readonly MAP_SCALE_STEP: number = 0.25

  @State private isLoading: boolean = false
  @State private allHistoryList: RecognitionHistoryItem[] = []
  @State private markerList: RecognitionMapMarker[] = []
  @State private selectedMarkerId: string = ''
  @State private mapScale: number = 1
  @State private selectedBirdId: number = -1
  @State private selectedBirdNameZh: string = ''
  @State private selectedBirdNameLatin: string = ''
  @State private selectedBirdPoster: string = ''
  @State private selectedLocationName: string = ''
  @State private selectedConfidence: number = 0
  @State private selectedRecognizedAt: number = 0
  @State private selectedLatitude: number = 0
  @State private selectedLongitude: number = 0

  aboutToAppear(): void {
    this.loadRecognitionHistory()
  }

  private async loadRecognitionHistory(): Promise<void> {
    if (this.isLoading) {
      return
    }

    this.isLoading = true
    try {
      const historyList: RecognitionHistoryItem[] = await BirdBackendService.fetchRecognitionHistory(120)
      const previousSelectedId: string = this.selectedMarkerId
      this.allHistoryList = historyList
      this.markerList = historyList
        .filter((item: RecognitionHistoryItem) =>
          item.latitude !== undefined && item.latitude !== null &&
          item.longitude !== undefined && item.longitude !== null
        )
        .map((item: RecognitionHistoryItem) => this.toMarker(item))

      if (this.markerList.length === 0) {
        this.resetSelection()
      } else {
        let restoredMarker: RecognitionMapMarker | null = null
        for (let i: number = 0; i < this.markerList.length; i++) {
          if (this.markerList[i].id === previousSelectedId) {
            restoredMarker = this.markerList[i]
            break
          }
        }

        if (restoredMarker !== null) {
          this.applySelection(restoredMarker)
        } else {
          this.applySelection(this.markerList[0])
        }
      }
    } catch (_e) {
      this.allHistoryList = []
      this.markerList = []
      this.resetSelection()
      promptAction.showToast({ message: '识别地图加载失败，请检查后端服务。' })
    } finally {
      this.isLoading = false
    }
  }

  private goBack() {
    try {
      router.back()
    } catch (_e) {
      router.replaceUrl({ url: 'pages/HomePage' })
    }
  }

  private toMarker(item: RecognitionHistoryItem): RecognitionMapMarker {
    const latitude: number = item.latitude as number
    const longitude: number = item.longitude as number
    return {
      id: item.id,
      birdId: item.birdId,
      birdNameZh: item.birdNameZh,
      birdNameLatin: item.birdNameLatin,
      birdPoster: item.birdPoster,
      locationName: item.locationName,
      confidence: item.confidence,
      recognizedAt: item.recognizedAt,
      latitude: latitude,
      longitude: longitude
    }
  }

  private mapRenderWidth(): number {
    return this.MAP_BASE_WIDTH * this.mapScale
  }

  private mapRenderHeight(): number {
    return this.MAP_BASE_HEIGHT * this.mapScale
  }

  private mapInsetLeft(): number {
    return this.mapRenderWidth() * this.MAP_FRAME_LEFT_RATIO
  }

  private mapInsetRight(): number {
    return this.mapRenderWidth() * this.MAP_FRAME_RIGHT_RATIO
  }

  private mapInsetTop(): number {
    return this.mapRenderHeight() * this.MAP_FRAME_TOP_RATIO
  }

  private mapInsetBottom(): number {
    return this.mapRenderHeight() * this.MAP_FRAME_BOTTOM_RATIO
  }

  private mapInnerWidth(): number {
    return this.mapRenderWidth() - this.mapInsetLeft() - this.mapInsetRight()
  }

  private mapInnerHeight(): number {
    return this.mapRenderHeight() - this.mapInsetTop() - this.mapInsetBottom()
  }

  private longitudeToX(longitude: number): number {
    const shiftedLongitude: number = ((longitude - this.MAP_LEFT_BOUNDARY_LONGITUDE) % 360 + 360) % 360
    const ratio: number = shiftedLongitude / 360
    return this.mapInsetLeft() + ratio * this.mapInnerWidth()
  }

  private latitudeToY(latitude: number): number {
    const ratio: number = (90 - latitude) / 180
    return this.mapInsetTop() + ratio * this.mapInnerHeight()
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

  private formatCoordinate(marker: RecognitionMapMarker): string {
    return `${marker.latitude.toFixed(4)}, ${marker.longitude.toFixed(4)}`
  }

  private selectedCoordinateText(): string {
    return `${this.selectedLatitude.toFixed(4)}, ${this.selectedLongitude.toFixed(4)}`
  }

  private selectedLocationText(): string {
    if (this.selectedLocationName.length > 0) {
      return this.selectedLocationName
    }
    return this.selectedCoordinateText()
  }

  private zoomOut() {
    this.mapScale = Math.max(this.MAP_SCALE_MIN, this.mapScale - this.MAP_SCALE_STEP)
  }

  private zoomIn() {
    this.mapScale = Math.min(this.MAP_SCALE_MAX, this.mapScale + this.MAP_SCALE_STEP)
  }

  private resetZoom() {
    this.mapScale = 1
  }

  private openBirdDetail(birdId: number) {
    if (birdId <= 0) {
      promptAction.showToast({ message: '当前标记暂时无法跳转到鸟类详情。' })
      return
    }
    router.pushUrl({ url: 'pages/BirdDetail', params: { birdId: birdId } })
  }

  private resetSelection() {
    this.selectedMarkerId = ''
    this.selectedBirdId = -1
    this.selectedBirdNameZh = ''
    this.selectedBirdNameLatin = ''
    this.selectedBirdPoster = ''
    this.selectedLocationName = ''
    this.selectedConfidence = 0
    this.selectedRecognizedAt = 0
    this.selectedLatitude = 0
    this.selectedLongitude = 0
  }

  private applySelection(marker: RecognitionMapMarker) {
    this.selectedMarkerId = marker.id
    this.selectedBirdId = marker.birdId
    this.selectedBirdNameZh = marker.birdNameZh
    this.selectedBirdNameLatin = marker.birdNameLatin
    this.selectedBirdPoster = marker.birdPoster
    this.selectedLocationName = marker.locationName
    this.selectedConfidence = marker.confidence
    this.selectedRecognizedAt = marker.recognizedAt
    this.selectedLatitude = marker.latitude
    this.selectedLongitude = marker.longitude
  }

  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => this.goBack())

      Text('识别记录地图')
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
  SummaryCard() {
    Row() {
      Column({ space: 6 }) {
        Text(`${this.allHistoryList.length}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1B5E20')
        Text('识别记录')
          .fontSize(12)
          .fontColor('#5F6B62')
      }
      .layoutWeight(1)

      Column({ space: 6 }) {
        Text(`${this.markerList.length}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1565C0')
        Text('地图标记')
          .fontSize(12)
          .fontColor('#5F6B62')
      }
      .layoutWeight(1)

      Column({ space: 6 }) {
        Text(`${Math.max(this.allHistoryList.length - this.markerList.length, 0)}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#EF6C00')
        Text('缺少坐标')
          .fontSize(12)
          .fontColor('#5F6B62')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }

  @Builder
  MapBoard() {
    Stack() {
      Image($r('app.media.world_map'))
        .width(this.mapRenderWidth())
        .height(this.mapRenderHeight())
        .objectFit(ImageFit.Fill)
        .borderRadius(22)

      Row() {}
        .width(this.mapRenderWidth())
        .height(this.mapRenderHeight())
        .backgroundColor('rgba(8, 30, 52, 0.08)')
        .borderRadius(22)

      Column({ space: 0 }) {
        Blank()
          .width('100%')
          .height(1)
          .backgroundColor('rgba(255, 255, 255, 0.22)')
        Blank().layoutWeight(1)
        Blank()
          .width('100%')
          .height(1)
          .backgroundColor('rgba(255, 255, 255, 0.22)')
        Blank().layoutWeight(1)
        Blank()
          .width('100%')
          .height(1)
          .backgroundColor('rgba(255, 255, 255, 0.22)')
      }
      .width(this.mapRenderWidth())
      .height(this.mapRenderHeight())

      Row({ space: 0 }) {
        Blank()
          .width(1)
          .height('100%')
          .backgroundColor('rgba(255, 255, 255, 0.18)')
        Blank().layoutWeight(1)
        Blank()
          .width(1)
          .height('100%')
          .backgroundColor('rgba(255, 255, 255, 0.18)')
        Blank().layoutWeight(1)
        Blank()
          .width(1)
          .height('100%')
          .backgroundColor('rgba(255, 255, 255, 0.18)')
        Blank().layoutWeight(1)
        Blank()
          .width(1)
          .height('100%')
          .backgroundColor('rgba(255, 255, 255, 0.18)')
      }
      .width(this.mapRenderWidth())
      .height(this.mapRenderHeight())

      ForEach(this.markerList, (item: RecognitionMapMarker, index: number) => {
        Stack() {
          Circle()
            .width(item.id === this.selectedMarkerId ? 24 : 18)
            .height(item.id === this.selectedMarkerId ? 24 : 18)
            .fill(item.id === this.selectedMarkerId ? '#E53935' : '#FF7043')
            .stroke('#FFFFFF')
            .strokeWidth(2)
            .shadow({
              radius: item.id === this.selectedMarkerId ? 10 : 6,
              color: 'rgba(0, 0, 0, 0.25)',
              offsetX: 0,
              offsetY: 2
            })

          Circle()
            .width(6)
            .height(6)
            .fill('#FFFFFF')
        }
        .position({ x: this.longitudeToX(item.longitude), y: this.latitudeToY(item.latitude) })
        .onClick(() => {
          this.applySelection(item)
        })
      }, (item: RecognitionMapMarker) => item.id)
    }
    .width(this.mapRenderWidth())
    .height(this.mapRenderHeight())
    .borderRadius(22)
    .border({ width: 1, color: 'rgba(76, 175, 80, 0.18)' })
  }

  @Builder
  MapSection() {
    Column({ space: 10 }) {
      Row() {
        Text('地图缩放')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank().layoutWeight(1)

        Text(`${this.mapScale.toFixed(2)}x`)
          .fontSize(12)
          .fontColor('#666666')

        Button('-')
          .width(32)
          .height(32)
          .margin({ left: 10 })
          .backgroundColor('#E8F5E9')
          .fontColor('#2E7D32')
          .enabled(this.mapScale > this.MAP_SCALE_MIN)
          .onClick(() => this.zoomOut())

        Button('1x')
          .width(42)
          .height(32)
          .margin({ left: 8 })
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .onClick(() => this.resetZoom())

        Button('+')
          .width(32)
          .height(32)
          .margin({ left: 8 })
          .backgroundColor('#4CAF50')
          .fontColor('#FFFFFF')
          .enabled(this.mapScale < this.MAP_SCALE_MAX)
          .onClick(() => this.zoomIn())
      }
      .width('100%')

      Text('当前底图使用标准世界地图内框进行换算，并按这张图的太平洋视角经线重新映射。若边缘仍有轻微偏差，可继续微调内框边距。')
        .fontSize(11)
        .fontColor('#7A7A7A')
        .width('100%')

      Scroll() {
        this.MapBoard()
      }
      .scrollable(ScrollDirection.Horizontal)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(22)
    }
    .width('100%')
  }

  @Builder
  SelectedMarkerCard() {
    if (this.selectedMarkerId.length === 0) {
      Column({ space: 10 }) {
        Text('暂无可展示的地图标记')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Text('当前识别记录里还没有带经纬度的数据。你可以先在真机上完成一次识别，再回来查看标记效果。')
          .fontSize(13)
          .lineHeight(22)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 22, bottom: 22 })
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
    } else {
      this.SelectedMarkerDetail()
    }
  }

  @Builder
  SelectedMarkerDetail() {
    Row() {
      Image(mapPosterResource(this.selectedBirdPoster))
        .width(74)
        .height(74)
        .borderRadius(14)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#E8F5E9')

      Column({ space: 6 }) {
        Text(this.selectedBirdNameZh.length > 0 ? this.selectedBirdNameZh : '未知鸟类')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(1)

        Text(this.selectedBirdNameLatin.length > 0 ? this.selectedBirdNameLatin : '暂无学名')
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(1)

        Text(`位置：${this.selectedLocationText()}`)
          .fontSize(12)
          .fontColor('#666666')

        Text(`经纬度：${this.selectedCoordinateText()}`)
          .fontSize(12)
          .fontColor('#666666')

        Text(`识别时间：${this.formatTime(this.selectedRecognizedAt)}`)
          .fontSize(12)
          .fontColor('#666666')

        Text(`置信度：${this.formatConfidence(this.selectedConfidence)}`)
          .fontSize(12)
          .fontColor('#4CAF50')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 12, right: 4 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .onClick(() => this.openBirdDetail(this.selectedBirdId))
  }

  @Builder
  MarkerListCard() {
    Column({ space: 12 }) {
      Row() {
        Text('最近的地图标记')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Blank().layoutWeight(1)
        Text(`${this.markerList.length} 条`)
          .fontSize(12)
          .fontColor('#5F6B62')
      }
      .width('100%')

      if (this.markerList.length === 0) {
        Text('暂时没有带坐标的识别记录，地图页仍可正常打开，等后续拿到真机定位后这里就会自动出现标记。')
          .fontSize(13)
          .lineHeight(22)
          .fontColor('#666666')
          .width('100%')
      } else {
        Column({ space: 10 }) {
          ForEach(this.markerList.slice(0, 6), (item: RecognitionMapMarker) => {
            Row() {
              Circle()
                .width(10)
                .height(10)
                .fill(item.id === this.selectedMarkerId ? '#1B5E20' : '#4CAF50')

              Column({ space: 4 }) {
                Text(item.birdNameZh.length > 0 ? item.birdNameZh : item.birdNameLatin)
                  .fontSize(14)
                  .fontWeight(item.id === this.selectedMarkerId ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor('#333333')
                  .maxLines(1)

                Text(`${this.formatCoordinate(item)} · ${this.formatTime(item.recognizedAt)}`)
                  .fontSize(11)
                  .fontColor('#7A7A7A')
                  .maxLines(1)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 10 })

              Image($r('app.media.ic_arrow_right'))
                .width(16)
                .height(16)
                .fillColor('#BDBDBD')
            }
            .width('100%')
            .padding({ left: 4, right: 4, top: 6, bottom: 6 })
            .onClick(() => {
              this.applySelection(item)
            })
          }, (item: RecognitionMapMarker) => item.id)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }

  build() {
    Column() {
      this.TopBar()

      if (this.isLoading) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(38)
            .height(38)
            .color('#4CAF50')
          Text('正在加载识别地图...')
            .fontSize(14)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            this.SummaryCard()
            this.MapSection()
            this.SelectedMarkerCard()
            this.MarkerListCard()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
