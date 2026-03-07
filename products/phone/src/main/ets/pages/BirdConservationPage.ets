// BirdConservationPage.ets
import router from '@ohos.router';

interface VolunteerRole {
  role: string;
  req: string;
}

@Entry
@Component
struct BirdConservationPage {
  @State activeTab: number = 0;   // 0科普 1资讯 2公益
  private tabs: string[] = ['保护科普', '行业资讯'];

  // ✅ 修改：改为 replaceUrl 跳转到首页，与你的首页跳转模式一致
  backToHome() {
    router.replaceUrl({
      url: 'pages/HomePage'  // 直接跳转到你的首页
    });
  }

  build() {
    Column({ space: 0 }) {
      // 1. 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#fff')
          .onClick(this.backToHome);  // 点击返回
        Blank();
        Text('鸟类保护与资讯').fontSize(18).fontColor('#fff');
        Blank();
        Blank().width(24);
      }
      .width('100%').height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#4CAF50');

      // 2. Tab 切换
      Row() {
        ForEach(this.tabs, (item: string, idx: number) => {
          Text(item)
            .fontSize(idx === this.activeTab ? 16 : 14)
            .fontColor(idx === this.activeTab ? '#4CAF50' : '#666')
            .fontWeight(idx === this.activeTab ? FontWeight.Bold : FontWeight.Normal)
            .height(40).padding({ left: 20, right: 20 })
            .onClick(() => this.activeTab = idx);
        });
      }
      .width('100%')
      .backgroundColor('#F5F5F5')
      .justifyContent(FlexAlign.Center);

      // 3. 内容区
      Scroll() {
        Column({ space: 16 }) {
          if (this.activeTab === 0) this.ProtectionSection();
          if (this.activeTab === 1) this.NewsSection();
          if (this.activeTab === 2) this.DonateSection();
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off);
    }
    .width('100%').height('100%')
    .backgroundColor('#FFFFFF');
  }

  // 板块1：保护科普
  @Builder
  ProtectionSection() {
    Column({ space: 12 }) {
      Text('国家一级保护鸟类').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333');
      ConservationCard({
        title: '中华秋沙鸭',
        level: '一级',
        img: $r('app.media.bird_merganser'),
        desc: '全球不足 3000 只，栖息于清澈河流，需保护原生阔叶林与无污染水体。'
      });
      ConservationCard({
        title: '黄腹角雉',
        level: '一级',
        img: $r('app.media.bird_tragopan'),
        desc: '中国特有雉类，依赖原始常绿林，禁止捕猎与林地开发。'
      });

      Text('栖息地保护小贴士').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333');
      ForEach(
        ['减少塑料垃圾，避免鸟类误食',
          '不惊扰、不投喂，保持 50 米以上观察距离',
          '参与本地湿地清理志愿活动'],
        (txt: string) => {
          Row() {
            Circle().width(6).height(6).fill('#4CAF50');
            Text(txt).fontSize(14).fontColor('#555').padding({ left: 8 });
          }
          .width('100%')
          .padding(10)
          .backgroundColor('#F1F8E9')
          .borderRadius(8);
        }
      );
    }
  }

  // 板块2：行业资讯
  @Builder
  NewsSection() {
    Column({ space: 12 }) {
      ActivityCard({
        title: '元旦东滩观鸟节',
        date: '2025-11-01 08:00',
        spot: '崇明东滩',
        img: $r('app.media.news_dongtan')
      });
      ActivityCard({
        title: '市区夜观猫头鹰',
        date: '2025-12-31 19:00',
        spot: '世纪公园',
        img: $r('app.media.news_owl')
      });
      NewsCard({
        title: '我国新增 3 种鸟类记录',
        summary: '中科院动物所团队在云南发现新种啄木鸟，成果发表于《Ibis》。',
        img: $r('app.media.news_discovery')
      });
    }
  }

  // 板块3：公益入口
  @Builder
  DonateSection() {
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
            Button('申请').height(32).backgroundColor('#4CAF50').fontSize(12);
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F5F5F5')
          .borderRadius(8);
        }
      );
    }
  }
}

// 子组件：保护卡片
@Component
struct ConservationCard {
  title: string = '';
  level: string = '';
  img: Resource = $r('app.media.icon');
  desc: string = '';

  build() {
    Row() {
      Image(this.img).width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover);
      Column({ space: 6 }) {
        Row() {
          Text(this.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333');
          Blank();
          Text(this.level).fontSize(12).fontColor('#fff')
            .backgroundColor('#FF9800').borderRadius(4).padding({ left: 6, right: 6 });
        }.width('100%');
        Text(this.desc).fontSize(13).fontColor('#666').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1).padding({ left: 12 }).alignItems(HorizontalAlign.Start);
    }
    .width('100%').backgroundColor('#F9F9F9').borderRadius(12).padding(12);
  }
}

// 子组件：活动卡片
@Component
struct ActivityCard {
  title: string = '';
  date: string = '';
  spot: string = '';
  img: Resource = $r('app.media.icon');

  build() {
    Stack() {
      Image(this.img).width('100%').height(160).borderRadius(12).objectFit(ImageFit.Cover);
      Column() {
        Row() {
          Text(this.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#fff');
          Blank();
        }.width('100%');
        Blank();
        Row() {
          Image($r('app.media.ic_time')).width(14).height(14).fillColor('#fff');
          Text(this.date).fontSize(12).fontColor('#fff').padding({ left: 4 });
          Blank();
          Image($r('app.media.ic_location')).width(14).height(14).fillColor('#fff');
          Text(this.spot).fontSize(12).fontColor('#fff').padding({ left: 4 });
        }.width('100%')
      }
      .padding(12).width('100%').height('100%')
      .backgroundColor('rgba(0,0,0,0.3)')
      .borderRadius(12)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%').height(160).borderRadius(12);
  }
}

// 子组件：新闻卡片
@Component
struct NewsCard {
  title: string = '';
  summary: string = '';
  img: Resource = $r('app.media.icon');

  build() {
    Row() {
      Image(this.img).width(100).height(70).borderRadius(8).objectFit(ImageFit.Cover);
      Column({ space: 4 }) {
        Text(this.title).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333')
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis });
        Text(this.summary).fontSize(13).fontColor('#666')
          .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1).padding({ left: 10 }).alignItems(HorizontalAlign.Start);
    }
    .width('100%').backgroundColor('#FAFAFA').borderRadius(10).padding(10);
  }
}