// BirdDetailPage.ets
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

interface Bird {
  id: string
  nameZh: string
  nameLatin: string
  family: string
  habitat: string
  distribution: string
  livingHabits: string
  breeding: string
  protection: string
  poster: Resource
  related: Bird[]
}
interface NavItem {
  name: string
  icon: Resource
  route?: string
}
/* 路由参数取鸟对象 */
const params = router.getParams() as Record<string, Bird>

@Entry
@Component
struct BirdDetailPage {

  @State isShowPublishDialog: boolean = false
  @State selectedImages: string[] = []
  @State postContent: string = ''
  @State selectedTags: string[] = []

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

  private handleNavClick(index: number): void {
    this.currentNavIndex = index;       // 高亮切换
    // 下面再写路由 or toast
    promptAction.showToast({ message: this.navList[index].name });
  }
  @State isRefreshing: boolean = false
  @State currentTab: 'all' | 'friends' = 'all'

  @State bird: Bird = params?.bird ?? this.mockBird()
  @State isLiked: boolean = false
  @State noteText: string = ''
  @State showNotePanel: boolean = false
  @State showSharePanel: boolean = false
  /* ✅ 返回图鉴页面 */
  goBack() {
    router.replaceUrl({
      url: 'pages/BirdGallery'
    });
  }
  build() {
    Column() {
      this.TopBar()
    Scroll() {
      Column({ space: 16 }) {
        /* 1. 顶部大图 = 沉浸体验 */
        this.HeroImage()
        /* 2. 基础信息 */
        this.BaseInfoCard()
        /* 3. 高密度科普档案 */
        this.KnowledgeCard()
        /* 4. 关联推荐 */
        this.RelatedCard()
      }
      .padding({ left: 16, right: 16, bottom: 32 })
    }
    .layoutWeight(1)            // 关键：占剩余全部高度
    .scrollBar(BarState.Off)
      this.BottomBar()
      /* 2. 底部导航：固定 56 dp */

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')

  }
  @Builder
  TopBar() {
    Row() {
      /* 返回按钮 */
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333')
          .onClick(this.goBack);
      }
      .width(40)



      Text('鸟类详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      /* 占位，保持对称 */
      Blank()
        .width(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
    .backgroundColor('#FFFFFF')
  }
  /* -------------------- 区域组件 -------------------- */
  @Builder
  HeroImage() {
    Image(this.bird.poster)
      .width('100%')
      .height(240)
      .borderRadius(16)
      .objectFit(ImageFit.Cover)
  }


  @Builder
  BaseInfoCard() {
    Column() {
      Row() {
        Column() {
          Text(this.bird.nameZh).fontSize(26).fontWeight(FontWeight.Bold)
          Text(this.bird.nameLatin).fontSize(14).fontColor('#666')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(this.bird.family).fontSize(12).fontColor('#999')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('#F0F0F0').borderRadius(4)
      }

      /* 沉浸式导语 */
      Text('沉浸式观赏与高密度知识，一次看个够。')
        .fontSize(14).fontColor('#777').margin({ top: 8 })
    }
    .padding(16).backgroundColor('#FFFFFF').borderRadius(16)
  }

  @Builder
  KnowledgeCard() {
    Column({ space: 12 }) {
      Text('科普档案').fontSize(18).fontWeight(FontWeight.Medium)

      this.TwoCol('科属分类', this.bird.family)
      this.TwoCol('栖息地分布', this.bird.habitat)
      this.TwoCol('生活习性', this.bird.livingHabits)
      this.TwoCol('繁殖特点', this.bird.breeding)
      this.TwoCol('保护等级', this.bird.protection)
    }
    .padding(16).backgroundColor('#FFFFFF').borderRadius(16)
  }

  @Builder
  TwoCol(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor('#777').width(90)
      Text(value).fontSize(14).fontColor('#333').layoutWeight(1)
    }
  }

  @Builder
  RelatedCard() {
    Column({ space: 12 }) {
      Text('关联推荐').fontSize(18).fontWeight(FontWeight.Medium)
      if (this.bird.related.length === 0) {
        Text('暂无更多').fontSize(12).fontColor('#999')
      } else {
        Scroll() {
          Row() {
            ForEach(this.bird.related, (r: Bird) => {
              Column() {
                Image(r.poster).width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover)
                Text(r.nameZh).fontSize(12).fontColor('#333').margin({ top: 4 })
              }
              .margin({ right: 12 })
              .onClick(() => router.pushUrl({ url: 'pages/BirdGallery', params: { bird: r } }))
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
    }
    .padding(16).backgroundColor('#FFFFFF').borderRadius(16)
  }

  /* -------------------- 悬浮功能条 -------------------- */
  @Builder
  FloatBar() {
    Row({ space: 12 }) {
      this.Fab($r('app.media.heart'), this.isLiked ? '#FF4444' : '#999', () => {
        this.isLiked = !this.isLiked
        promptAction.showToast({ message: this.isLiked ? '已收藏' : '取消收藏' })
      })
      this.Fab($r('app.media.note'), '#4CAF50', () => this.showNotePanel = true)
      this.Fab($r('app.media.share'), '#2196F3', () => this.showSharePanel = true)
    }
    .padding({ right: 20, bottom: 20 })

    if (this.showNotePanel) this.NotePanel()
    if (this.showSharePanel) this.SharePanel()
  }

  @Builder
  Fab(img: Resource, color: string, cb: () => void) {
    Image(img).width(24).height(24).fillColor(color)
      .padding(12).backgroundColor('#FFF').borderRadius(24)
      .shadow({ radius: 4, color: '#20000000' }).onClick(cb)
  }

  /* 笔记面板 */
  @Builder
  NotePanel() {
    Column() {
      Row() {
        Text('我的笔记').fontSize(16).fontWeight(FontWeight.Medium)
        Blank()
        Image($r('app.media.close')).width(20).height(20)
          .onClick(() => this.showNotePanel = false)
      }.width('100%').padding({ bottom: 12 })

      TextArea({ placeholder: '记录观察细节…', text: this.noteText })
        .width('100%').height(120).onChange(v => this.noteText = v)

      Button('保存')
        .width('100%').height(40).backgroundColor('#4CAF50').borderRadius(20).margin({ top: 12 })
        .onClick(() => {
          promptAction.showToast({ message: '笔记已保存' })
          this.showNotePanel = false
        })
    }
    .padding(16).backgroundColor('#FFFFFF').borderRadius(16)
    .position({ x: 20, y: -180 }).width('80%')
  }

  /* 分享面板 */
  @Builder
  SharePanel() {
    Row({ space: 20 }) {
      Column() {
        Image($r('app.media.share_friend')).width(36).height(36)
        Text('好友').fontSize(12).margin({ top: 4 })
      }.onClick(() => {
        promptAction.showToast({ message: '已分享到社交模块' })
        this.showSharePanel = false
      })
    }
    .padding({ top: 12, bottom: 12, left: 24, right: 24 })
    .backgroundColor('#FFFFFF').borderRadius(16)
    .position({ x: 20, y: -80 }).shadow({ radius: 4, color: '#20000000' })
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

  /* Mock 数据 */
  private mockBird(): Bird {
    return {
      id: '1',
      nameZh: '红嘴蓝鹊',
      nameLatin: 'Urocissa erythrorhyncha',
      family: '鸦科',
      habitat: '阔叶林、混交林、林缘及村落附近',
      distribution: '中国华东、华中、华南及西南',
      livingHabits: '杂食，集群活动，善鸣叫',
      breeding: '4–6 月营巢于乔木，每窝 3–5 卵',
      protection: '国家“三有”保护鸟类',
      poster: $r('app.media.Urocissa_erythroryncha'),
      related: []
    }
  }
}