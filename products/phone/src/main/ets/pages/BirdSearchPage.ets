import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { BirdApiItem, BirdBackendService, mapPosterResource } from '../services/BirdBackendService'

interface SearchBird {
  id: number
  nameZh: string
  nameLatin: string
  family: string
  habitat: string
  protection: string
  poster: Resource
  tags: string[]
}

@Entry
@Component
struct BirdSearchPage {
  @State keyword: string = ''
  @State family: string = ''
  @State habitat: string = ''
  @State historyList: string[] = []
  @State hotList: string[] = ['麻雀', '珠颈斑鸠', '红嘴蓝鹊', '白头鹎', '乌鸫']
  @State suggestList: string[] = []
  @State resultList: SearchBird[] = []
  @State allBirds: SearchBird[] = []
  @State isLoading: boolean = false
  @State hasSearched: boolean = false

  onPageShow() {
    if (this.historyList.length === 0) {
      this.historyList = ['麻雀', '乌鸫']
    }
  }

  aboutToAppear(): void {
    this.loadBirdsFromApi()
  }

  private normalizeText(value: string | null | undefined): string {
    if (value === null || value === undefined) {
      return ''
    }
    return value.trim()
  }

  private buildTags(bird: SearchBird): string[] {
    const tags: string[] = []
    if (bird.family.length > 0) {
      tags.push(bird.family)
    }
    if (bird.habitat.length > 0) {
      tags.push(bird.habitat)
    }
    if (bird.protection.length > 0) {
      tags.push(bird.protection)
    }
    return tags.slice(0, 3)
  }

  private mapBird(item: BirdApiItem): SearchBird {
    const bird: SearchBird = {
      id: item.birdId,
      nameZh: this.normalizeText(item.birdNameZh),
      nameLatin: this.normalizeText(item.birdNameLatin),
      family: this.normalizeText(item.birdFamily),
      habitat: this.normalizeText(item.birdHabitat),
      protection: this.normalizeText(item.birdProtection),
      poster: mapPosterResource(item.birdPoster),
      tags: []
    }
    bird.tags = this.buildTags(bird)
    return bird
  }

  private async loadBirdsFromApi(): Promise<void> {
    if (this.isLoading) {
      return
    }

    this.isLoading = true
    try {
      const remoteBirds: BirdApiItem[] = await BirdBackendService.fetchBirds()
      const birds: SearchBird[] = remoteBirds.map((item: BirdApiItem) => this.mapBird(item))

      if (birds.length === 0) {
        promptAction.showToast({ message: '数据库暂无鸟类数据' })
        return
      }

      this.allBirds = birds
      this.hotList = birds
        .slice(0, Math.min(5, birds.length))
        .map((bird: SearchBird) => bird.nameZh)

      if (this.keyword.length > 0 || this.family.length > 0 || this.habitat.length > 0) {
        this.doSearch()
      }
    } catch (_e) {
      promptAction.showToast({ message: '鸟类数据加载失败，请检查后端服务' })
    } finally {
      this.isLoading = false
    }
  }

  onKeywordChange(value: string) {
    this.keyword = value
    const inputText: string = this.normalizeText(value).toLowerCase()
    if (inputText.length === 0) {
      this.suggestList = []
      return
    }

    const suggestions: string[] = []
    this.allBirds.forEach((bird: SearchBird) => {
      const matchZh: boolean = bird.nameZh.toLowerCase().includes(inputText)
      const matchLatin: boolean = bird.nameLatin.toLowerCase().includes(inputText)
      if ((matchZh || matchLatin) && suggestions.indexOf(bird.nameZh) === -1) {
        suggestions.push(bird.nameZh)
      }
    })
    this.suggestList = suggestions.slice(0, 8)
  }

  onTagClick(text: string) {
    this.keyword = text
    this.suggestList = []
    this.doSearch()
  }

  private matchesKeyword(bird: SearchBird, keyword: string): boolean {
    if (keyword.length === 0) {
      return true
    }

    const normalizedKeyword: string = keyword.toLowerCase()
    return bird.nameZh.toLowerCase().includes(normalizedKeyword) ||
      bird.nameLatin.toLowerCase().includes(normalizedKeyword) ||
      bird.family.toLowerCase().includes(normalizedKeyword) ||
      bird.habitat.toLowerCase().includes(normalizedKeyword) ||
      bird.protection.toLowerCase().includes(normalizedKeyword)
  }

  doSearch() {
    const normalizedKeyword: string = this.normalizeText(this.keyword)
    const normalizedFamily: string = this.normalizeText(this.family)
    const normalizedHabitat: string = this.normalizeText(this.habitat)

    if (normalizedKeyword.length === 0 && normalizedFamily.length === 0 && normalizedHabitat.length === 0) {
      promptAction.showToast({ message: '请至少输入一个搜索条件' })
      return
    }

    if (this.allBirds.length === 0) {
      promptAction.showToast({ message: '鸟类数据尚未加载完成' })
      return
    }

    if (normalizedKeyword.length > 0 && this.historyList.indexOf(normalizedKeyword) === -1) {
      this.historyList = [normalizedKeyword, ...this.historyList].slice(0, 10)
    }

    this.hasSearched = true
    this.suggestList = []
    this.resultList = this.allBirds.filter((bird: SearchBird) =>
      this.matchesKeyword(bird, normalizedKeyword) &&
      (normalizedFamily.length > 0 ? bird.family.includes(normalizedFamily) : true) &&
      (normalizedHabitat.length > 0 ? bird.habitat.includes(normalizedHabitat) : true)
    )
  }

  goDetail(bird: SearchBird) {
    router.push({ url: 'pages/BirdDetail', params: { birdId: bird.id } })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#4CAF50')
          .onClick(() => router.replaceUrl({ url: 'pages/HomePage' }))
        Blank()
        Text('鸟类速查')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
        Blank()
      }
      .width('100%')
      .padding(16)

      Column() {
        Column() {
          TextInput({ placeholder: '中文名/拉丁名/保护等级', text: this.keyword })
            .onChange((value: string) => this.onKeywordChange(value))
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(12)
            .padding(10)

          if (this.suggestList.length > 0) {
            Column() {
              ForEach(this.suggestList, (item: string) => {
                Row() {
                  Text(item)
                    .fontSize(14)
                    .fontColor('#666666')
                }
                .width('100%')
                .padding(8)
                .onClick(() => this.onTagClick(item))
              })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .padding(8)
            .margin({ top: 4 })
          }

          Row() {
            TextInput({ placeholder: '科属', text: this.family })
              .onChange((value: string) => this.family = value)
              .layoutWeight(1)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding(10)
            Blank().width(8)
            TextInput({ placeholder: '栖息地', text: this.habitat })
              .onChange((value: string) => this.habitat = value)
              .layoutWeight(1)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding(10)
          }
          .width('100%')
          .margin({ top: 12 })

          Button('搜索')
            .width('100%')
            .height(44)
            .backgroundColor('#4CAF50')
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => this.doSearch())
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        Row() {
          Text('热门')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
          Blank()
          Text('历史')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding({ top: 16, bottom: 8 })

        Row({ space: 12 }) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.hotList, (hot: string) => {
              Text(hot)
                .fontSize(12)
                .fontColor('#4CAF50')
                .backgroundColor('#E8F5E9')
                .borderRadius(4)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => this.onTagClick(hot))
            })
          }
          .layoutWeight(1)

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.historyList, (history: string) => {
              Text(history)
                .fontSize(12)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(4)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => this.onTagClick(history))
            })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16, right: 16, top: 8, bottom: 12 })

      if (this.isLoading) {
        Column() {
          Text('正在从数据库加载鸟类数据...')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .padding({ left: 16, right: 16, top: 12 })
      } else if (this.hasSearched && this.resultList.length === 0) {
        Column() {
          Text('未找到匹配的鸟类')
            .fontSize(16)
            .fontColor('#333333')
          Text('可以换个关键词，或尝试只输入科属、栖息地再搜索')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 })
      } else if (this.resultList.length > 0) {
        Scroll() {
          Column() {
            Text(`共 ${this.resultList.length} 条结果`)
              .fontSize(14)
              .fontColor('#999999')
              .padding({ top: 4, bottom: 8 })

            ForEach(this.resultList, (bird: SearchBird) => {
              Row() {
                Image(bird.poster)
                  .width(56)
                  .height(56)
                  .borderRadius(28)
                  .objectFit(ImageFit.Cover)
                  .backgroundColor('#E8F5E9')

                Column() {
                  Text(bird.nameZh.length > 0 ? bird.nameZh : '未知鸟类')
                    .fontSize(16)
                    .fontColor('#333333')
                    .maxLines(1)
                  Text(bird.nameLatin.length > 0 ? bird.nameLatin : '暂无拉丁名')
                    .fontSize(12)
                    .fontColor('#999999')
                    .maxLines(1)
                  Row() {
                    ForEach(bird.tags, (tag: string) => {
                      Text(tag)
                        .fontSize(10)
                        .fontColor('#4CAF50')
                        .backgroundColor('#E8F5E9')
                        .borderRadius(2)
                        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                        .margin({ right: 4 })
                    })
                  }
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                .padding({ left: 12 })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .margin({ bottom: 8 })
              .onClick(() => this.goDetail(bird))
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, bottom: 32 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      } else {
        Blank()
          .layoutWeight(1)
      }
    }
    .backgroundColor('#F5F5F5')
    .height('100%')
  }
}
