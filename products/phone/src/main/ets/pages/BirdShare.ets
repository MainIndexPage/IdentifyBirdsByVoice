import router from '@ohos.router'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import promptAction from '@ohos.promptAction'
import { BirdBackendService, CommunityPostItem, CreateCommunityPostPayload } from '../services/BirdBackendService'

interface BirdPost {
  id: string
  userId: string
  userName: string
  userAvatar: string
  birdName: string
  birdImage: string
  description: string
  tags: string[]
  location: string
  timestamp: number
  likes: number
  comments: number
  shares: number
  isLiked: boolean
  privacy: PrivacyType
  images?: string[]
  video?: string
}

enum PrivacyType {
  PUBLIC = '公开',
  FRIENDS = '好友可见',
  PRIVATE = '仅自己'
}

enum ShareType {
  BIRD_RECOGNITION = '识别结果',
  PHOTO = '观鸟照片',
  VIDEO = '观鸟视频'
}

interface NavItem {
  name: string
  icon: Resource
  route: string
}

@Entry
@Component
struct BirdSharingPage {
  @State currentUserId: string = ''

  @State posts: BirdPost[] = []
  @State isShowPublishDialog: boolean = false
  @State selectedImages: string[] = []
  @State postContent: string = ''
  @State selectedTags: string[] = []
  @State selectedPrivacy: PrivacyType = PrivacyType.PUBLIC
  @State shareType: ShareType = ShareType.PHOTO
  @State currentTab: 'all' | 'friends' = 'all'
  @State hotTags: string[] = ['#今日识鸟#', '#城市观鸟#', '#迁徙季#', '#保护野生鸟类#']

  @State currentNavIndex: number = 3
  private navItems: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '听声识鸟', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社区', icon: $r('app.media.nav_community'), route: 'pages/BirdSharePage' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ]

  aboutToAppear() {
    this.currentUserId = BirdBackendService.getLoginUserId()
    this.loadPostsFromBackend()
  }

  private navClick(index: number) {
    if (index === this.currentNavIndex) return
    router.replaceUrl({ url: this.navItems[index].route })
    this.currentNavIndex = index
  }

  private loadMockData() {
    this.posts = [
      {
        id: '1',
        userId: 'user1',
        userName: '观鸟爱好者A',
        userAvatar: 'https://example.com/avatar1.jpg',
        birdName: '红嘴蓝鹊',
        birdImage: 'https://miaobi-lite.bj.bcebos.com/miaobi/5mao/b%2756u55p6X5Luj6KGo5LuA5LmI5Yqo54mpXzE3MzQwMjMxNDMuMjU4MzIxNQ%3D%3D%27/0.png',
        description: '今天在公园拍到了红嘴蓝鹊，羽毛颜色非常漂亮。',
        tags: ['#今日识鸟#', '#红嘴蓝鹊#'],
        location: '中山公园',
        timestamp: Date.now() - 3600000,
        likes: 12,
        comments: 3,
        shares: 1,
        isLiked: false,
        privacy: PrivacyType.PUBLIC
      }
    ]
  }

  private async loadPostsFromBackend() {
    try {
      const remotePosts: CommunityPostItem[] = await BirdBackendService.fetchCommunityPosts()
      if (remotePosts.length > 0) {
        this.posts = remotePosts.map((item: CommunityPostItem) => this.mapApiPost(item))
        return
      }
      this.loadMockData()
    } catch (_e) {
      this.loadMockData()
    }
  }

  private mapApiPost(item: CommunityPostItem): BirdPost {
    return {
      id: item.id,
      userId: item.userId,
      userName: item.userName,
      userAvatar: item.userAvatar || 'https://example.com/default_avatar.jpg',
      birdName: item.birdName,
      birdImage: item.birdImage || 'https://example.com/default_bird.jpg',
      description: item.description,
      tags: item.tags,
      location: item.location,
      timestamp: item.timestamp,
      likes: item.likes,
      comments: item.comments,
      shares: item.shares,
      isLiked: item.isLiked,
      privacy: this.privacyFromApi(item.privacy),
      images: item.images,
      video: item.video
    }
  }

  build() {
    Navigation() {
      Column() {
        this.TopNavigation()
        this.PublishButton()

        Stack() {
          Column() {
            this.TabSwitcher()
            List({ space: 12 }) {
              ForEach(this.posts, (post: BirdPost) => {
                ListItem() {
                  this.PostCard(post)
                }
              })
            }
            .layoutWeight(1)
            .backgroundColor('#F5F5F5')
            .padding({ left: 16, right: 16, bottom: 8 })
          }

          if (this.isShowPublishDialog) {
            this.PublishDialog()
          }
        }
        .layoutWeight(1)

        this.BottomBar()
      }
      .height('100%')
      .backgroundColor('#FFFFFF')
    }
    .hideBackButton(false)
  }

  @Builder
  TopNavigation() {
    Row() {
      Text('鸟类分享')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')
      Blank()
      Image($r('app.media.search'))
        .width(24)
        .height(24)
        .onClick(() => promptAction.showToast({ message: '搜索功能开发中...' }))
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  PublishButton() {
    Row() {
      Button('分享你的观鸟发现')
        .width('90%')
        .height(48)
        .backgroundColor('#4CAF50')
        .borderRadius(24)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .onClick(() => this.isShowPublishDialog = true)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  TabSwitcher() {
    Row() {
      Text('全部动态')
        .fontSize(16)
        .fontWeight(this.currentTab === 'all' ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTab === 'all' ? '#4CAF50' : '#999999')
        .padding({ bottom: 8 })
        .border({ width: { bottom: this.currentTab === 'all' ? 2 : 0 }, color: '#4CAF50' })
        .onClick(() => this.currentTab = 'all')

      Blank().width(40)

      Text('好友动态')
        .fontSize(16)
        .fontWeight(this.currentTab === 'friends' ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTab === 'friends' ? '#4CAF50' : '#999999')
        .padding({ bottom: 8 })
        .border({ width: { bottom: this.currentTab === 'friends' ? 2 : 0 }, color: '#4CAF50' })
        .onClick(() => {
          this.currentTab = 'friends'
          promptAction.showToast({ message: '好友动态开发中...' })
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  PostCard(post: BirdPost) {
    Column() {
      Row() {
        Image(post.userAvatar)
          .width(40)
          .height(40)
          .borderRadius(20)

        Column() {
          Text(post.userName)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2C3E50')
          Row() {
            Text(post.location || '未知位置').fontSize(12).fontColor('#999999')
            Text(' · ').fontSize(12).fontColor('#999999')
            Text(this.formatTime(post.timestamp)).fontSize(12).fontColor('#999999')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })

        Blank()

        Text(post.privacy)
          .fontSize(10)
          .fontColor('#999999')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('#F0F0F0')
          .borderRadius(4)

        if (this.canDeletePost(post)) {
          Blank().width(8)
          Text('删除')
            .fontSize(10)
            .fontColor('#FF4444')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#FFEDEE')
            .borderRadius(4)
            .onClick(() => this.deletePost(post))
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Image(post.birdImage)
        .width('100%')
        .height(200)
        .borderRadius(8)
        .margin({ top: 12 })
        .objectFit(ImageFit.Cover)

      Text(post.birdName)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')
        .margin({ top: 8 })

      Text(post.description)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })
        .lineHeight(20)

      if (post.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(post.tags, (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontColor('#4CAF50')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#E8F5E8')
              .borderRadius(12)
              .margin({ right: 8, bottom: 8 })
          })
        }
        .margin({ top: 8 })
        .width('100%')
      }

      Row() {
        Row() {
          Image(post.isLiked ? $r('app.media.heart_filled') : $r('app.media.heart'))
            .width(20)
            .height(20)
            .fillColor(post.isLiked ? '#FF4444' : '#999999')
          Text(post.likes.toString())
            .fontSize(14)
            .fontColor(post.isLiked ? '#FF4444' : '#999999')
            .margin({ left: 4 })
        }
        .onClick(() => this.toggleLike(post))

        Blank().width(32)

        Row() {
          Image($r('app.media.comment')).width(20).height(20).fillColor('#999999')
          Text(post.comments.toString()).fontSize(14).fontColor('#999999').margin({ left: 4 })
        }
        .onClick(() => promptAction.showToast({ message: '评论功能开发中...' }))

        Blank().width(32)

        Row() {
          Image($r('app.media.share')).width(20).height(20).fillColor('#999999')
          Text(post.shares.toString()).fontSize(14).fontColor('#999999').margin({ left: 4 })
        }
        .onClick(() => this.sharePost(post))
      }
      .margin({ top: 12 })
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  PublishDialog() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('分享观鸟发现').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#2C3E50')
            Blank()
            Image($r('app.media.close')).width(24).height(24).onClick(() => this.isShowPublishDialog = false)
          }
          .width('100%')
          .padding({ bottom: 16 })

          Text('分享类型').fontSize(14).fontColor('#666666').margin({ bottom: 8 })

          Row() {
            ForEach([ShareType.PHOTO, ShareType.VIDEO, ShareType.BIRD_RECOGNITION], (type: ShareType) => {
              Text(type)
                .fontSize(12)
                .fontColor(this.shareType === type ? '#FFFFFF' : '#4CAF50')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.shareType === type ? '#4CAF50' : '#E8F5E8')
                .borderRadius(16)
                .margin({ right: 8 })
                .onClick(() => this.shareType = type)
            })
          }
          .margin({ bottom: 16 })

          this.ImageUploadArea()

          TextArea({ placeholder: '分享你的观鸟心得...', text: this.postContent })
            .width('100%')
            .height(100)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
            .onChange((v: string) => this.postContent = v)
            .margin({ bottom: 16 })

          Text('选择话题标签').fontSize(14).fontColor('#666666').margin({ bottom: 8 })
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.hotTags, (tag: string) => {
              Text(tag)
                .fontSize(12)
                .fontColor(this.selectedTags.includes(tag) ? '#FFFFFF' : '#4CAF50')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.selectedTags.includes(tag) ? '#4CAF50' : '#E8F5E8')
                .borderRadius(16)
                .margin({ right: 8, bottom: 8 })
                .onClick(() => this.toggleTag(tag))
            })
          }
          .width('100%')

          Row() {
            Text('可见范围').fontSize(14).fontColor('#666666')
            Blank()
            Select([{ value: PrivacyType.PUBLIC }, { value: PrivacyType.FRIENDS }, { value: PrivacyType.PRIVATE }])
              .selected(this.getPrivacyIndex())
              .onSelect((i: number) => {
                const arr: PrivacyType[] = [PrivacyType.PUBLIC, PrivacyType.FRIENDS, PrivacyType.PRIVATE]
                this.selectedPrivacy = arr[i]
              })
          }
          .margin({ bottom: 20 })
          .width('100%')

          Button('发布分享')
            .width('100%')
            .height(44)
            .backgroundColor('#4CAF50')
            .borderRadius(22)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .margin({ bottom: 8 })
            .onClick(() => this.publishPost())
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .height('100%')
    }
    .width('90%')
    .padding(20)
    .height('80%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .position({ x: '5%', y: '10%' })
  }

  @Builder
  ImageUploadArea() {
    Column() {
      if (this.selectedImages.length === 0) {
        Row() {
          Column() {
            Image($r('app.media.add_image')).width(48).height(48).fillColor('#4CAF50')
            Text('上传图片').fontSize(14).fontColor('#4CAF50').margin({ top: 8 })
          }
        }
        .width('100%')
        .height(120)
        .backgroundColor('#F0F0F0')
        .borderRadius(8)
        .border({ width: 1, color: '#4CAF50', style: BorderStyle.Dashed })
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.selectImages())
      } else {
        Scroll() {
          Row() {
            ForEach(this.selectedImages, (image: string, idx: number) => {
              Stack() {
                Image(image).width(100).height(100).borderRadius(8).objectFit(ImageFit.Cover)
                Image($r('app.media.close'))
                  .width(20)
                  .height(20)
                  .fillColor('#FFFFFF')
                  .backgroundColor('#FF4444')
                  .borderRadius(10)
                  .position({ x: 80, y: 5 })
                  .onClick(() => this.selectedImages.splice(idx, 1))
              }
              .margin({ right: 8 })
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .margin({ bottom: 16 })
      }
    }
    .width('100%')
  }

  @Builder
  BottomBar() {
    Row() {
      ForEach(this.navItems, (item: NavItem, idx: number) => {
        Column() {
          Image(item.icon).width(24).height(24).fillColor(this.currentNavIndex === idx ? '#4CAF50' : '#999999')
          Text(item.name).fontSize(10).fontColor(this.currentNavIndex === idx ? '#4CAF50' : '#999999').margin({ top: 4 })
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

  private formatTime(ts: number): string {
    const diff = Date.now() - ts
    if (diff < 60000) return '刚刚'
    if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
    return `${Math.floor(diff / 86400000)}天前`
  }

  private async toggleLike(post: BirdPost) {
    const targetLiked: boolean = !post.isLiked
    post.isLiked = targetLiked
    post.likes += targetLiked ? 1 : -1

    try {
      const updated = await BirdBackendService.likeCommunityPost(post.id, targetLiked)
      if (updated) {
        post.likes = updated.likes
        post.isLiked = updated.isLiked
      }
    } catch (_e) {
      post.isLiked = !targetLiked
      post.likes += targetLiked ? -1 : 1
      promptAction.showToast({ message: '点赞失败，请稍后重试' })
    }
  }

  private sharePost(post: BirdPost) {
    post.shares += 1
    promptAction.showToast({ message: '分享成功' })
  }

  private toggleTag(tag: string) {
    const i = this.selectedTags.indexOf(tag)
    if (i > -1) {
      this.selectedTags.splice(i, 1)
    } else {
      this.selectedTags.push(tag)
    }
  }

  private getPrivacyIndex(): number {
    return [PrivacyType.PUBLIC, PrivacyType.FRIENDS, PrivacyType.PRIVATE].indexOf(this.selectedPrivacy)
  }

  private async selectImages() {
    try {
      const opt = new photoAccessHelper.PhotoSelectOptions()
      opt.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      opt.maxSelectNumber = 9
      const picker = new photoAccessHelper.PhotoViewPicker()
      const res = await picker.select(opt)
      if (res.photoUris && res.photoUris.length > 0) {
        this.selectedImages = res.photoUris
      }
    } catch (_e) {
      promptAction.showToast({ message: '选择图片失败' })
    }
  }

  private async publishPost() {
    if (!this.postContent && this.selectedImages.length === 0) {
      promptAction.showToast({ message: '请添加内容或图片' })
      return
    }

    const payload: CreateCommunityPostPayload = {
      userId: this.currentUserId,
      userName: '我',
      userAvatar: 'https://example.com/my_avatar.jpg',
      birdName: '未知鸟类',
      birdImage: this.selectedImages[0] || '',
      description: this.postContent,
      tags: this.selectedTags,
      location: '当前位置',
      privacy: this.privacyToApi(this.selectedPrivacy),
      images: this.selectedImages,
      video: ''
    }

    try {
      const created = await BirdBackendService.createCommunityPost(payload)
      if (created) {
        await this.loadPostsFromBackend()
        this.isShowPublishDialog = false
        this.resetPublishForm()
        promptAction.showToast({ message: '发布成功' })
        return
      }
      promptAction.showToast({ message: '发布失败，请稍后再试' })
    } catch (_e) {
      promptAction.showToast({ message: '发布失败，请检查后端是否启动' })
    }
  }

  private privacyToApi(privacy: PrivacyType): string {
    if (privacy === PrivacyType.FRIENDS) return 'FRIENDS'
    if (privacy === PrivacyType.PRIVATE) return 'PRIVATE'
    return 'PUBLIC'
  }

  private privacyFromApi(privacy: string): PrivacyType {
    if (privacy === 'FRIENDS') return PrivacyType.FRIENDS
    if (privacy === 'PRIVATE') return PrivacyType.PRIVATE
    return PrivacyType.PUBLIC
  }

  private canDeletePost(post: BirdPost): boolean {
    const me: string = this.currentUserId.trim()
    const owner: string = post.userId.trim()
    return me.length > 0 && owner === me
  }

  private async confirmDeletePost(): Promise<boolean> {
    try {
      const result = await promptAction.showDialog({
        title: '删除帖子',
        message: '确定要删除这条帖子吗？删除后无法恢复。',
        buttons: [
          { text: '取消', color: '#666666' },
          { text: '删除', color: '#FF4444' }
        ]
      })
      return result.index === 1
    } catch (_e) {
      return false
    }
  }

  private async deletePost(post: BirdPost) {
    const confirmed: boolean = await this.confirmDeletePost()
    if (!confirmed) return

    try {
      const ok: boolean = await BirdBackendService.deleteCommunityPost(post.id)
      if (!ok) {
        promptAction.showToast({ message: '删除失败，请稍后再试' })
        return
      }
      const index: number = this.posts.findIndex((item: BirdPost) => item.id === post.id)
      if (index >= 0) {
        this.posts.splice(index, 1)
      }
      promptAction.showToast({ message: '删除成功' })
    } catch (_e) {
      promptAction.showToast({ message: '删除失败，请检查后端是否启动' })
    }
  }

  private resetPublishForm() {
    this.selectedImages = []
    this.postContent = ''
    this.selectedTags = []
    this.selectedPrivacy = PrivacyType.PUBLIC
    this.shareType = ShareType.PHOTO
  }
}