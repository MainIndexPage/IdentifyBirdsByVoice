// BirdPublicWelfarePage.ets
import router from '@ohos.router';

interface VolunteerRole {
  role: string;
  req: string;
}

interface NavItem {
  name: string;
  icon: Resource;
  route: string;
}

@Entry
@Component
struct BirdPublicWelfarePage {
  @State currentNavIndex: number = -1;

  private navList: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '听音识鸟', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社群', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ];

  build() {
    Column({ space: 0 }) {
      // 1. 顶部导航栏（已修改返回按钮样式与逻辑）
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333')
          .onClick(() => {
            router.replaceUrl({ url: 'pages/HomePage' });
          });
        Blank();
        Text('公益入口').fontSize(18).fontColor('#fff');
        Blank();
        Blank().width(24);
      }
      .width('100%').height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#4CAF50');

      // 2. 内容区
      Scroll() {
        Column({ space: 20 }) {
          Image($r('app.media.img_donate_banner')).width('100%').borderRadius(12);
          Text('让候鸟安全回家').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#4CAF50');
          Text('您的每一份捐赠都将用于栖息地巡护、环志设备与公众科普。')
            .fontSize(14).fontColor('#666');

          Button('立即捐赠')
            .width('100%').height(48)
            .backgroundColor('#4CAF50').borderRadius(24)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/BirdCharityPage'
              });
            });

          Divider().color('#EEEEEE').strokeWidth(1);
          Text('成为志愿者').fontSize(18).fontWeight(FontWeight.Medium).fontColor('#333');

          ForEach([
            { role: '周末湿地巡护', req: '每月 2 次，提供保险与培训' },
            { role: '鸟类环志助理', req: '需体力好，候鸟季 3-5 月' },
            { role: '科普讲解志愿者', req: '周末在博物馆为小朋友讲解' }
          ] as VolunteerRole[],
            (item: VolunteerRole) => {
              Row() {
                Column() {
                  Text(item.role).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333');
                  Text(item.req).fontSize(12).fontColor('#666');
                }
                .layoutWeight(1);
                Button('申请').height(32).backgroundColor('#4CAF50').fontSize(12)
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/VolunteerApplicationPage'
                    });
                  });
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8);
            }
          );
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off);

      this.BottomBar();
    }
    .width('100%').height('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  BottomBar() {
    Row() {
      ForEach(this.navList, (item: NavItem, idx: number) => {
        Column() {
          Image(item.icon)
            .width(24)
            .height(24)
            .fillColor(this.currentNavIndex === idx ? '#4CAF50' : '#999');

          Text(item.name)
            .fontSize(10)
            .fontColor(this.currentNavIndex === idx ? '#4CAF50' : '#999')
            .margin({ top: 4 });
        }
        .layoutWeight(1)
        .onClick(() => {
          if (idx === this.currentNavIndex) return;
          const target = this.navList[idx].route;
          router.replaceUrl({ url: target });
          this.currentNavIndex = idx;
        });
      });
    }
    .width('100%')
    .height(56)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#E0E0E0' });
  }
}