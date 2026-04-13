import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { BirdApiItem, BirdBackendService, mapPosterResource, PosterSource } from '../services/BirdBackendService'

@Entry
@Component
struct BirdDetailPage {
  @State birdIdText: string = '-1'
  @State birdNameZh: string = '加载中...'
  @State birdNameLatin: string = '加载中...'
  @State birdFamily: string = '加载中...'
  @State birdHabitat: string = '加载中...'
  @State birdDistribution: string = '加载中...'
  @State birdLivingHabits: string = '加载中...'
  @State birdBreeding: string = '加载中...'
  @State birdProtection: string = '加载中...'
  @State birdIntro: string = '加载中...'
  @State birdPoster: PosterSource = $r('app.media.ic_close')

  aboutToAppear(): void {
    console.info('BirdDetail final aboutToAppear')
    this.loadBirdDetail()
  }

  private readBirdId(): number {
    const params = router.getParams() as Record<string, Object | string | number | undefined>
    const rawId = params.birdId ?? params.id

    if (typeof rawId === 'number' && !Number.isNaN(rawId)) {
      return rawId
    }

    if (typeof rawId === 'string') {
      const parsedValue: number = Number(rawId)
      if (!Number.isNaN(parsedValue)) {
        return parsedValue
      }
    }

    return -1
  }

  private textOrFallback(value: string | null | undefined, fallback: string): string {
    if (value === null || value === undefined) {
      return fallback
    }
    const trimmedValue: string = value.trim()
    return trimmedValue.length > 0 ? trimmedValue : fallback
  }

  private setFallbackData(): void {
    this.birdIdText = '-1'
    this.birdNameZh = '本地兜底数据'
    this.birdNameLatin = '暂无学名'
    this.birdFamily = '暂无科属信息'
    this.birdHabitat = '暂无栖息地信息'
    this.birdDistribution = '暂无分布信息'
    this.birdLivingHabits = '暂无生活习性信息'
    this.birdBreeding = '暂无繁殖信息'
    this.birdProtection = '暂无保护等级信息'
    this.birdIntro = '当前展示的是本地兜底数据。'
    this.birdPoster = $r('app.media.ic_close')
  }

  private applyBirdData(item: BirdApiItem): void {
    this.birdIdText = String(item.birdId)
    this.birdNameZh = this.textOrFallback(item.birdNameZh, '未知鸟类')
    this.birdNameLatin = this.textOrFallback(item.birdNameLatin, '暂无学名')
    this.birdFamily = this.textOrFallback(item.birdFamily, '暂无科属信息')
    this.birdHabitat = this.textOrFallback(item.birdHabitat, '暂无栖息地信息')
    this.birdDistribution = this.textOrFallback(item.birdDistribution, '暂无分布信息')
    this.birdLivingHabits = this.textOrFallback(item.birdLivingHabits, '暂无生活习性信息')
    this.birdBreeding = this.textOrFallback(item.birdBreeding, '暂无繁殖信息')
    this.birdProtection = this.textOrFallback(item.birdProtection, '暂无保护等级信息')
    this.birdIntro = this.textOrFallback(item.birdIntro, '暂无简介')
    this.birdPoster = mapPosterResource(item.birdPoster)
  }

  private async loadBirdDetail(): Promise<void> {
    const birdId: number = this.readBirdId()
    console.info(`BirdDetail final route birdId=${birdId}`)

    if (birdId <= 0) {
      this.setFallbackData()
      promptAction.showToast({ message: '未获取到鸟类ID，已使用本地数据' })
      return
    }

    try {
      const birdDetail: BirdApiItem | null = await BirdBackendService.fetchBirdById(birdId)
      console.info(`BirdDetail final fetchBirdById data=${JSON.stringify(birdDetail)}`)

      if (birdDetail === null) {
        this.setFallbackData()
        promptAction.showToast({ message: '未找到对应鸟类详情' })
        return
      }

      this.applyBirdData(birdDetail)
      console.info(`BirdDetail final state id=${this.birdIdText}, nameZh=${this.birdNameZh}`)
    } catch (_e) {
      this.setFallbackData()
      promptAction.showToast({ message: '详情加载失败，已使用本地数据' })
    }
  }

  private goBack(): void {
    try {
      router.back()
    } catch (_e) {
      router.replaceUrl({ url: 'pages/BirdGallery' })
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => this.goBack())

        Text('鸟类详情')
          .layoutWeight(1)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)

        Blank().width(24)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 14 }) {
            Image(this.birdPoster)
              .width('100%')
              .height(240)
              .borderRadius(18)
              .objectFit(ImageFit.Cover)

            Text(this.birdNameZh)
              .width('100%')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F1F1F')

            Text(this.birdNameLatin)
              .width('100%')
              .fontSize(16)
              .fontColor('#6B6B6B')

            Row({ space: 8 }) {
              Text(this.birdFamily)
                .fontSize(12)
                .fontColor('#2E7D32')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor('#E8F5E9')
                .borderRadius(12)

              Text(this.birdProtection)
                .fontSize(12)
                .fontColor('#C62828')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor('#FFEBEE')
                .borderRadius(12)
            }
            .width('100%')

            Text(this.birdIntro)
              .width('100%')
              .fontSize(15)
              .fontColor('#444444')
              .lineHeight(24)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)

          Column({ space: 0 }) {
            Text('科普信息')
              .width('100%')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F1F1F')
              .margin({ bottom: 8 })

            Text(`鸟类编号：${this.birdIdText}`)
              .width('100%')
              .fontSize(16)
              .fontColor('#222222')
              .lineHeight(24)
              .padding({ top: 10, bottom: 10 })

            Text(`科属分类：${this.birdFamily}`)
              .width('100%')
              .fontSize(16)
              .fontColor('#222222')
              .lineHeight(24)
              .padding({ top: 10, bottom: 10 })

            Text(`栖息地：${this.birdHabitat}`)
              .width('100%')
              .fontSize(16)
              .fontColor('#222222')
              .lineHeight(24)
              .padding({ top: 10, bottom: 10 })

            Text(`分布范围：${this.birdDistribution}`)
              .width('100%')
              .fontSize(16)
              .fontColor('#222222')
              .lineHeight(24)
              .padding({ top: 10, bottom: 10 })

            Text(`生活习性：${this.birdLivingHabits}`)
              .width('100%')
              .fontSize(16)
              .fontColor('#222222')
              .lineHeight(24)
              .padding({ top: 10, bottom: 10 })

            Text(`繁殖特点：${this.birdBreeding}`)
              .width('100%')
              .fontSize(16)
              .fontColor('#222222')
              .lineHeight(24)
              .padding({ top: 10, bottom: 10 })

            Text(`保护等级：${this.birdProtection}`)
              .width('100%')
              .fontSize(16)
              .fontColor('#222222')
              .lineHeight(24)
              .padding({ top: 10, bottom: 10 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F6F7F9')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7F9')
  }
}

