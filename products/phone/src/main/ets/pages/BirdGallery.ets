// entry/src/main/ets/pages/BirdGalleryPage.ets
import router from '@ohos.router'
import { Bird } from './BirdModel'

/* 模拟图鉴数据库 */
const BIRD_GALLERY: Bird[] = [
  {
    id: '1',
    nameZh: '红嘴蓝鹊',
    nameLatin: 'Urocissa erythrorhyncha',
    family: '鸦科',
    habitat: '阔叶林',
    protection: '三有',
    poster: $r('app.media.Urocissa_erythroryncha'),
    call: $r('app.media.voice')
  },
  {
    id: '2',
    nameZh: '黑脸琵鹭',
    nameLatin: 'Platalea minor',
    family: '鹮科',
    habitat: '湿地',
    protection: '一级',
    poster: $r('app.media.Platalea_minor'),
    call: $r('app.media.voice')
  },
  {
    id: '3',
    nameZh: '普通翠鸟',
    nameLatin: 'Alcedo atthis',
    family: '翠鸟科',
    habitat: '湿地',
    protection: '三有',
    poster: $r('app.media.Alcedo_atthis'),
    call: $r('app.media.voice')
  }
]
interface NavItem {
  name: string
  icon: Resource
  route: string
}
@Entry
@Component
struct BirdGalleryPage {
  @State list: Bird[] = BIRD_GALLERY

  @State currentNavIndex: number = 1
  private navList: NavItem[] = [
    { name:'首页', icon:$r('app.media.nav_home'), route:'pages/HomePage' },
    { name:'图鉴', icon:$r('app.media.nav_encyclopedia'), route:'pages/BirdGallery' },
    { name:'听音识鸟', icon:$r('app.media.nav_listen'), route:'pages/BirdSoundRecognitionPage' },
    { name:'社群', icon:$r('app.media.nav_community'), route:'pages/BirdShare' },
    { name:'我的', icon:$r('app.media.nav_profile'), route:'pages/ProfilePage' }
  ]

  private navClick(index: number) {
    if (index === this.currentNavIndex) return
    const target = this.navList[index].route
    router.replaceUrl({ url: target })
    this.currentNavIndex = index
  }


  build() {
    Column() {
      /* 顶部标题栏 */
      Row() {
        Text('鸟类图鉴')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)

      /* 图鉴列表 */
      List({ space: 12 }) {
        ForEach(this.list, (bird: Bird) => {
          ListItem() {
            this.BirdRow(bird)
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/BirdDetail', params: { bird } })
          })
        })
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .padding({ left: 16, right: 16 })
      this.BottomBar()
    }
    .width('100%')
    .height('100%')
  }

  /* 单行 UI */
  @Builder
  BirdRow(bird: Bird) {
    Row({ space: 12 }) {
      Image(bird.poster)
        .width(80)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column({ space: 4 }) {
        Text(bird.nameZh)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(bird.nameLatin)
          .fontSize(12)
          .fontColor('#666')
        Row({ space: 6 }) {
          this.Tag(bird.family)
          this.Tag(bird.habitat)
          this.Tag(bird.protection)
        }
      }
      .layoutWeight(1)

      /* 播放叫声占位按钮（无音频逻辑） */
      Image($r('app.media.voice'))
        .width(24)
        .height(24)
        .fillColor('#4CAF50')
        .onClick((e: ClickEvent) => {

        })
    }
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
  @Builder
  BottomBar() {
    Row() {
      ForEach(this.navList, (item: NavItem, idx: number) => {
        Column() {
          Image(item.icon)
            .width(24)
            .height(24)
            .fillColor(this.currentNavIndex === idx ? '#4CAF50' : '#999')
          Text(item.name)
            .fontSize(10)
            .fontColor(this.currentNavIndex === idx ? '#4CAF50' : '#999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => this.navClick(idx))
      })
    }
    .width('100%')
    .height(56)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#E0E0E0' })
  }
  /* 标签 */
  @Builder
  Tag(text: string) {
    Text(text)
      .fontSize(10)
      .fontColor('#FFF')
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      .backgroundColor('#4CAF50')
      .borderRadius(4)
  }

}