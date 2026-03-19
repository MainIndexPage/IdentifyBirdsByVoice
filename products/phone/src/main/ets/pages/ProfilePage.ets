// ProfilePage.ets
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { TARGET_NAME } from 'BuildProfile'

/* ================== 数据模型 ================== */
interface Record {
  id: number
  title: string
  time: string
  tag: string
}

/* ================== 底部导航 ================== */
interface NavItem {
  name: string
  icon: Resource
  route: string
}

/* ================== 新增：好友数据模型 ================== */
interface Friend {
  id: number
  name: string
  avatar: string
}

/* ================== 新增：活动数据模型 ================== */
interface Activity {
  id: number
  title: string
  time: string
  location: string
}

@Entry
@Component
struct ProfilePage {
  /* -------------- 个人中心 -------------- */
  @State userName: string = '观鸟人'
  @State avatar: string = ''
  @State collectCount: number = 12
  @State noteCount: number = 8
  @State historyCount: number = 35
  @State historyList: Record[] = [
    {id:1, title:'白头鹎-2025-12-30', time:'08:30', tag:'林地'},
    {id:2, title:'麻雀-2025-12-29', time:'18:15', tag:'村落'},
    {id:3, title:'红嘴蓝鹊-2025-12-28', time:'07:05', tag:'林栖'},
  ]

  /* -------------- 新增：好友列表状态 -------------- */
  @State friendList: Friend[] = [
    {id:1, name:'鸟友小李', avatar:''},
    {id:2, name:'观鸟达人', avatar:''},
    {id:3, name:'林间漫步', avatar:''},
    {id:4, name:'羽翼观察者', avatar:''},
  ]

  /* -------------- 新增：活动列表状态 -------------- */
  @State activityList: Activity[] = [
    {id:1, title:'春季候鸟观测活动', time:'2025-03-15 06:00', location:'浦东新区世纪公园'},
    {id:2, title:'校园观鸟科普展', time:'2025-03-20 14:00', location:'复旦大学'},
  ]

  /* -------------- 底部导航 -------------- */
  private navList: NavItem[] = [
    { name:'首页', icon:$r('app.media.nav_home'), route:'pages/HomePage' },
    { name:'图鉴', icon:$r('app.media.nav_encyclopedia'), route:'pages/BirdGallery' },
    { name:'林声识羽', icon:$r('app.media.nav_listen'), route:'pages/BirdSoundRecognitionPage' },
    { name:'社群', icon:$r('app.media.nav_community'), route:'pages/BirdShare' },
    { name:'我的', icon:$r('app.media.nav_profile'), route:'pages/ProfilePage' }
  ]
  @State currentNavIndex: number = 4   // 当前页高亮

  /* -------------- 跳转 (修复了原逻辑，现在会使用传入的 path) -------------- */
  private jump(path: string) {
    router.replaceUrl({ url: path })
  }

  /* -------------- 底部栏Builder -------------- */
  @Builder
  BottomBar() {
    Row() {
      ForEach(this.navList, (item: NavItem, idx: number) => {
        Column() {
          Image(item.icon)
            .width(24).height(24)
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

  private navClick(index: number) {
    if (index === this.currentNavIndex) return
    // 1. 拼出绝对路径；2. 不要以 "/" 开头
    const target = this.navList[index].route   // 例如 "pages/HomePage"
    router.replaceUrl({ url: target })            // 直接跳
    this.currentNavIndex = index
  }

  /* -------------- UI -------------- */
  build() {
    Navigation(){
      Column(){
        Scroll(){
          Column({ space: 12 }){
            /* 1. 个人信息 */
            Row(){
              Stack(){
                if(this.avatar){
                  Image(this.avatar).width(64).height(64).borderRadius(32)
                }else{
                  Text(this.userName.substr(0,1)).fontSize(32).fontColor('#FFFFFF')
                }
              }
              .width(64).height(64).borderRadius(32).backgroundColor('#4CAF50')
              .alignContent(Alignment.Center)

              Column(){
                Text(this.userName).fontSize(20).fontColor('#333')
                Text('编辑资料').fontSize(12).fontColor('#4CAF50').margin({top:4})
              }.margin({left:12}).layoutWeight(1)

              SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(20)
            }
            .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
            .onClick(()=>this.jump('pages/EditProfilePage'))

            /* 2. 快速统计 */
            Row(){
              this.statItem('收藏', this.collectCount, 'pages/MyCollectPage')
              Divider().vertical(true).strokeWidth(1).color('#E0E0E0').height(24)
              this.statItem('笔记', this.noteCount, 'pages/MyNotePage')
              Divider().vertical(true).strokeWidth(1).color('#E0E0E0').height(24)
              this.statItem('识别', this.historyCount, 'pages/RecognizeHistoryPage')
            }
            .width('100%').padding({top:12, bottom:12}).backgroundColor('#FFFFFF').borderRadius(12)

            /* 3. 识别历史 */
            Column(){
              Row(){
                Text('识别历史').fontSize(16).fontColor('#333').fontWeight(FontWeight.Medium)
                Blank()
                Text('全部').fontSize(14).fontColor('#4CAF50')
                  .onClick(()=>this.jump('pages/RecognizeHistoryPage'))
              }.padding({bottom:8})
              ForEach(this.historyList, (r:Record)=>{
                Row(){
                  Column(){
                    Text(r.title).fontSize(14).fontColor('#333')
                    Text(`${r.time} · ${r.tag}`).fontSize(12).fontColor('#999').margin({top:2})
                  }.layoutWeight(1)
                  SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(16)
                }
                .width('100%').padding({top:8, bottom:8})
                .onClick(()=>this.jump(`pages/RecordDetailPage?id=${r.id}`))
              })
            }
            .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)

            /* ================== 新增：4. 好友展示 ================== */
            Column(){
              Row(){
                Text('好友').fontSize(16).fontColor('#333').fontWeight(FontWeight.Medium)
                Blank()
                Text('全部').fontSize(14).fontColor('#4CAF50')
                  .onClick(()=>this.jump('pages/FriendListPage'))
              }.padding({bottom:8})
              Row({ space: 12 }){
                ForEach(this.friendList, (f:Friend)=>{
                  Column(){
                    Stack(){
                      if(f.avatar){
                        Image(f.avatar).width(48).height(48).borderRadius(24)
                      }else{
                        Text(f.name.substr(0,1)).fontSize(20).fontColor('#FFFFFF')
                      }
                    }
                    .width(48).height(48).borderRadius(24).backgroundColor('#81C784')
                    .alignContent(Alignment.Center)
                    Text(f.name).fontSize(12).fontColor('#666').margin({top:4})
                  }
                  .onClick(()=>this.jump(`pages/FriendDetailPage?id=${f.id}`))
                })
              }
            }
            .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)

            /* ================== 新增：5. 活动展示 ================== */
            Column(){
              Row(){
                Text('活动').fontSize(16).fontColor('#333').fontWeight(FontWeight.Medium)
                Blank()
                Text('全部').fontSize(14).fontColor('#4CAF50')
                  .onClick(()=>this.jump('pages/ActivityListPage'))
              }.padding({bottom:8})
              ForEach(this.activityList, (a:Activity)=>{
                Row(){
                  Column(){
                    Text(a.title).fontSize(14).fontColor('#333')
                    Text(`${a.time} · ${a.location}`).fontSize(12).fontColor('#999').margin({top:2})
                  }.layoutWeight(1)
                  SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(16)
                }
                .width('100%').padding({top:8, bottom:8})
                .onClick(()=>this.jump(`pages/ActivityDetailPage?id=${a.id}`))
              })
            }
            .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)

            /* 6. 系统设置 (序号顺延) */
            List(){
              ListItem(){ this.cell('隐私政策', 'pages/PrivacyPage') }
              ListItem(){ this.cell('通知设置', 'pages/NotifySettingPage') }
              ListItem(){ this.cell('音效设置', 'pages/SoundSettingPage') }
              ListItem(){ this.cell('关于APP', 'pages/AboutPage') }
            }
            .width('100%').backgroundColor('#FFFFFF').borderRadius(12)
            .divider({ strokeWidth: 0.5, color: '#E0E0E0' })
            .padding({ left: 16, right: 16 })
            .edgeEffect(EdgeEffect.None)
          }
          .padding({ left: 16, right: 16, top: 0, bottom: 32 })
        }
        .layoutWeight(1)
        /* 底部导航栏 */
        this.BottomBar()
      }
      .height('100%')
    }
    .title('我的')
    .hideBackButton(false)
    .backgroundColor('#F5F5F5')
  }

  /* -------------- Builder -------------- */
  @Builder statItem(label: string, num: number, path: string){
    Column(){
      Text(`${num}`).fontSize(20).fontColor('#4CAF50').fontWeight(FontWeight.Medium)
      Text(label).fontSize(12).fontColor('#666').margin({top:4})
    }
    .layoutWeight(1).alignItems(HorizontalAlign.Center)
    .onClick(()=>this.jump(path))
  }

  @Builder cell(title: string, path: string){
    Row(){
      Text(title).fontSize(14).fontColor('#333')
      Blank()
      SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(16)
    }
    .width('100%').padding({ top: 14, bottom: 14 })
    .onClick(()=>this.jump(path))
  }
}