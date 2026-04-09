// BirdConservationPage.ets
import router from '@ohos.router';

interface BirdSpecies {
  name: string;
  level: string;
  img: Resource;
  desc: string;
  habitat: string;
  threat: string;
}

interface ConservationTip {
  icon: Resource;
  title: string;
  content: string;
}

interface NewsItem {
  title: string;
  date: string;
  source: string;
  summary: string;
  img: Resource;
  tag: string;
}

interface ActivityItem {
  title: string;
  date: string;
  spot: string;
  img: Resource;
  type: string;
  participants: string;
}

@Entry
@Component
struct BirdConservationPage {
  @State activeTab: number = 0;
  private tabs: string[] = ['保护科普', '行业资讯'];

  // 国家一级保护鸟类数据
  private protectedBirds: BirdSpecies[] = [
    {
      name: '中华秋沙鸭',
      level: '一级',
      img: $r('app.media.bird_merganser'),
      desc: '全球不足3000只，是第三纪冰川期后残存下来的物种，距今已有1000多万年。',
      habitat: '清澈河流、湖泊，需要原生阔叶林',
      threat: '栖息地破坏、水体污染'
    },
    {
      name: '黄腹角雉',
      level: '一级',
      img: $r('app.media.bird_tragopan'),
      desc: '中国特有雉类，因腹部羽毛呈皮黄色而得名，有"鸟中大熊猫"之称。',
      habitat: '海拔800-1400米山地常绿阔叶林',
      threat: '森林砍伐、非法捕猎'
    },
    {
      name: '黑鹳',
      level: '一级',
      img: $r('app.media.Ciconia_nigra'),
      desc: '体态优美，体色鲜明，活动敏捷，性情机警的大型涉禽。',
      habitat: '河流、沼泽、湿地',
      threat: '湿地萎缩、农药污染'
    },
    {
      name: '朱鹮',
      level: '一级',
      img: $r('app.media.Nipponia_nippon'),
      desc: '曾一度濒临灭绝，经过保护目前种群数量已恢复至数千只。',
      habitat: '水田、沼泽、山地森林',
      threat: '曾濒临灭绝，现持续恢复中'
    }
  ];

  // 保护小贴士数据
  private tips: ConservationTip[] = [
    {
      icon: $r('app.media.ic_no_plastic'),
      title: '减少塑料污染',
      content: '塑料垃圾会被鸟类误食，每年导致数百万只鸟类死亡。使用可重复利用的购物袋，妥善处理垃圾。'
    },
    {
      icon: $r('app.media.ic_distance'),
      title: '保持安全距离',
      content: '观鸟时保持50米以上距离，不使用无人机惊扰，不播放鸟鸣录音诱拍，让鸟类自然栖息。'
    },
    {
      icon: $r('app.media.ic_wetland'),
      title: '保护湿地环境',
      content: '参与本地湿地清理活动，不随意采摘水生植物，不向水体排放污染物，维护鸟类家园。'
    },
    {
      icon: $r('app.media.ic_window'),
      title: '防鸟撞玻璃',
      content: '在窗户上张贴防撞贴纸，尤其是高层建筑，每年减少数百万只鸟类因撞击玻璃而死亡。'
    },
    {
      icon: $r('app.media.ic_cat'),
      title: '科学养宠',
      content: '家猫是野生鸟类的主要威胁之一，外出时为猫佩戴铃铛，或建造户外猫舍限制活动范围。'
    },
    {
      icon: $r('app.media.ic_plant'),
      title: '种植本土植物',
      content: '在阳台或庭院种植本土树种，为鸟类提供食物和筑巢材料，打造城市中的鸟类友好空间。'
    }
  ];

  // 新闻资讯数据
  private newsList: NewsItem[] = [
    {
      title: '我国新增3种鸟类记录',
      date: '2026-03-15',
      source: '中科院动物研究所',
      summary: '科研团队在云南高黎贡山发现新种啄木鸟，相关成果发表于国际鸟类学期刊《Ibis》，丰富了我国鸟类多样性记录。',
      img: $r('app.media.news_discovery'),
      tag: '科研发现'
    },
    {
      title: '候鸟迁徙通道保护工程启动',
      date: '2026-03-10',
      source: '国家林业和草原局',
      summary: '覆盖东亚-澳大利西亚迁徙路线的20个关键栖息地纳入重点保护，建立跨国界保护协作机制。',
      img: $r('app.media.news_migration'),
      tag: '政策动态'
    },
    {
      title: '城市鸟类多样性调查报告发布',
      date: '2026-03-05',
      source: '中国观鸟会',
      summary: '报告显示北上广深等一线城市鸟类种类五年增长15%，城市绿地建设成效显著。',
      img: $r('app.media.news_urban'),
      tag: '调查报告'
    },
    {
      title: '打击非法鸟类贸易专项行动',
      date: '2026-02-28',
      source: '公安部',
      summary: '全国公安机关开展"清风行动"，破获特大非法猎捕、贩卖野生鸟类案件120余起。',
      img: $r('app.media.news_law'),
      tag: '执法行动'
    }
  ];

  // 活动数据
  private activities: ActivityItem[] = [
    {
      title: '春季候鸟迁徙观测',
      date: '2026-04-20 06:00',
      spot: '北京野鸭湖湿地',
      img: $r('app.media.activity_spring'),
      type: '观鸟活动',
      participants: '限30人'
    },
    {
      title: '城市公园鸟类调查',
      date: '2026-04-13 07:00',
      spot: '上海世纪公园',
      img: $r('app.media.activity_park'),
      type: '公民科学',
      participants: '开放报名'
    },
    {
      title: '湿地生态摄影工作坊',
      date: '2026-04-25 08:30',
      spot: '杭州西溪湿地',
      img: $r('app.media.activity_photo'),
      type: '摄影培训',
      participants: '限20人'
    }
  ];

  backToHome() {
    router.replaceUrl({
      url: 'pages/HomePage'
    });
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#fff')
          .onClick(this.backToHome);
        Blank();
        Text('鸟类保护与资讯').fontSize(18).fontColor('#fff').fontWeight(FontWeight.Medium);
        Blank();
        Blank().width(24);
      }
      .width('100%').height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#4CAF50');

      // Tab 切换
      Row() {
        ForEach(this.tabs, (item: string, idx: number) => {
          Column() {
            Text(item)
              .fontSize(idx === this.activeTab ? 16 : 14)
              .fontColor(idx === this.activeTab ? '#4CAF50' : '#666')
              .fontWeight(idx === this.activeTab ? FontWeight.Bold : FontWeight.Normal);
            if (idx === this.activeTab) {
              Divider()
                .width(20)
                .height(3)
                .color('#4CAF50')
                .margin({ top: 4 });
            } else {
              Blank().height(7);
            }
          }
          .height(44)
          .padding({ left: 24, right: 24 })
          .onClick(() => this.activeTab = idx);
        });
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .border({ width: { bottom: 1 }, color: '#EEEEEE' });

      // 内容区
      Scroll() {
        Column({ space: 0 }) {
          if (this.activeTab === 0) this.ProtectionSection();
          if (this.activeTab === 1) this.NewsSection();
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F5F5');
  }

  // 板块1：保护科普（内容丰富）
  @Builder
  ProtectionSection() {
    Column({ space: 16 }) {
      // 头部横幅
      Stack() {
        Image($r('app.media.banner_conservation'))
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover);
        Column() {
          Text('守护飞羽精灵').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#fff');
          Text('每一种鸟类都是生态系统不可或缺的一环').fontSize(14).fontColor('#fff').margin({ top: 8 });
        }
        .backgroundColor('rgba(0,0,0,0.4)')
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      }
      .width('100%')
      .borderRadius(0);

      Column({ space: 20 }) {
        // 重点保护鸟类
        Column({ space: 12 }) {
          Row() {
            Text('重点保护鸟类').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333');
            Text('查看更多 >').fontSize(14).fontColor('#4CAF50');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

          ForEach(this.protectedBirds, (bird: BirdSpecies) => {
            ConservationCard({ bird: bird });
          });
        };

        // 保护行动指南
        Column({ space: 12 }) {
          Text('保护行动指南').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333').width('100%');

          Grid() {
            ForEach(this.tips, (tip: ConservationTip, index: number) => {
              GridItem() {
                TipCard({ tip: tip });
              }
            });
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .width('100%');
        };

        // 保护数据展示
        Column({ space: 12 }) {
          Text('保护成效').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333').width('100%');

          Row() {
            StatCard({ number: '1445', label: '中国鸟类种数', trend: '+3种/年' });
            StatCard({ number: '394', label: '国家重点保护鸟类', trend: '严格保护' });
            StatCard({ number: '50+', label: '候鸟迁飞通道', trend: '跨国协作' });
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        };

        // 法律法规
        Column({ space: 12 }) {
          Text('法律法规').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333').width('100%');

          Column({ space: 8 }) {
            LawCard({
              title: '《中华人民共和国野生动物保护法》',
              content: '禁止猎捕、杀害国家重点保护野生动物，违者将承担刑事责任。'
            });
            LawCard({
              title: '《国家重点保护野生动物名录》',
              content: '2021年更新，鸟类保护级别调整，新增大量物种为重点保护对象。'
            });
            LawCard({
              title: 'CITES公约',
              content: '濒危野生动植物种国际贸易公约，中国于1981年正式加入。'
            });
          };
        };

        // 底部留白
        Blank().height(20);
      }
      .padding(16);
    }
  }

  // 板块2：行业资讯（内容丰富）
  @Builder
  NewsSection() {
    Column({ space: 16 }) {
      // 搜索栏
      Row() {
        Image($r('app.media.ic_search')).width(20).height(20).fillColor('#999');
        TextInput({ placeholder: '搜索鸟类资讯、活动...' })
          .placeholderColor('#999')
          .fontSize(14)
          .backgroundColor('transparent')
          .layoutWeight(1)
          .margin({ left: 8 });
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(22)
      .margin(16);

      Column({ space: 20 }) {
        // 近期活动
        Column({ space: 12 }) {
          Row() {
            Text('近期活动').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333');
            Text('全部活动 >').fontSize(14).fontColor('#4CAF50');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 16, right: 16 });

          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.activities, (activity: ActivityItem) => {
                ActivityCard({ activity: activity });
              });
            }
            .padding({ left: 16, right: 16 });
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off);
        };

        // 最新资讯
        Column({ space: 12 }) {
          Row() {
            Text('最新资讯').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333');
            Text('更多 >').fontSize(14).fontColor('#4CAF50');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 16, right: 16 });

          Column({ space: 12 }) {
            ForEach(this.newsList, (news: NewsItem) => {
              NewsCard({ news: news });
            });
          }
          .padding({ left: 16, right: 16 });
        };

        // 科普视频推荐
        Column({ space: 12 }) {
          Text('科普推荐').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333').width('100%');

          Scroll() {
            Row({ space: 12 }) {
              VideoCard({
                title: '候鸟迁徙的奥秘',
                duration: '12:30',
                img: $r('app.media.video_migration')
              });
              VideoCard({
                title: '如何识别常见水鸟',
                duration: '08:45',
                img: $r('app.media.video_waterbirds')
              });
              VideoCard({
                title: '城市观鸟入门指南',
                duration: '15:20',
                img: $r('app.media.video_guide')
              });
            }
            .padding({ left: 16, right: 16 });
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off);
        };

        // 底部留白
        Blank().height(20);
      };
    }
  }
}

// 子组件：保护鸟类卡片（增强版）
@Component
struct ConservationCard {
  @ObjectLink bird: BirdSpecies;

  build() {
    Column({ space: 0 }) {
      Row({ space: 12 }) {
        Image(this.bird.img)
          .width(100)
          .height(100)
          .borderRadius(8)
          .objectFit(ImageFit.Cover);

        Column({ space: 6 }) {
          Row() {
            Text(this.bird.name)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333');
            Blank();
            Text(this.bird.level)
              .fontSize(11)
              .fontColor('#fff')
              .backgroundColor('#FF5722')
              .borderRadius(4)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 });
          }
          .width('100%');

          Text(this.bird.desc)
            .fontSize(13)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Row() {
            Image($r('app.media.ic_habitat')).width(14).height(14).fillColor('#4CAF50');
            Text('栖息地：' + this.bird.habitat)
              .fontSize(12)
              .fontColor('#4CAF50')
              .margin({ left: 4 })
              .layoutWeight(1);
          }
          .width('100%');

          Row() {
            Image($r('app.media.ic_warning')).width(14).height(14).fillColor('#FF9800');
            Text('威胁：' + this.bird.threat)
              .fontSize(12)
              .fontColor('#FF9800')
              .margin({ left: 4 })
              .layoutWeight(1);
          }
          .width('100%');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%');
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 });
  }
}

// 子组件：保护小贴士卡片
@Component
struct TipCard {
  @ObjectLink tip: ConservationTip;

  build() {
    Column({ space: 8 }) {
      Image(this.tip.icon)
        .width(40)
        .height(40)
        .fillColor('#4CAF50');
      Text(this.tip.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .textAlign(TextAlign.Center);
      Text(this.tip.content)
        .fontSize(12)
        .fontColor('#666')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(140)
    .padding(12)
    .backgroundColor('#E8F5E9')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center);
  }
}

// 子组件：统计数据卡片
@Component
struct StatCard {
  number: string = '';
  label: string = '';
  trend: string = '';

  build() {
    Column({ space: 4 }) {
      Text(this.number)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4CAF50');
      Text(this.label)
        .fontSize(12)
        .fontColor('#666');
      Text(this.trend)
        .fontSize(11)
        .fontColor('#4CAF50')
        .backgroundColor('#E8F5E9')
        .borderRadius(4)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 });
    }
    .width('30%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 });
  }
}

// 子组件：法律法规卡片
@Component
struct LawCard {
  title: string = '';
  content: string = '';

  build() {
    Column({ space: 6 }) {
      Text(this.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .width('100%');
      Text(this.content)
        .fontSize(13)
        .fontColor('#666')
        .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: { left: 4 }, color: '#4CAF50' })
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 });
  }
}

// 子组件：活动卡片（横向滑动版）
@Component
struct ActivityCard {
  @ObjectLink activity: ActivityItem;

  build() {
    Column({ space: 0 }) {
      Stack() {
        Image(this.activity.img)
          .width(280)
          .height(160)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .objectFit(ImageFit.Cover);

        Text(this.activity.type)
          .fontSize(12)
          .fontColor('#fff')
          .backgroundColor('#4CAF50')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .position({ x: 12, y: 12 });
      }
      .width(280);

      Column({ space: 6 }) {
        Text(this.activity.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%');

        Row() {
          Image($r('app.media.ic_time')).width(14).height(14).fillColor('#666');
          Text(this.activity.date)
            .fontSize(12)
            .fontColor('#666')
            .margin({ left: 4 });
        }
        .width('100%');

        Row() {
          Image($r('app.media.ic_location')).width(14).height(14).fillColor('#666');
          Text(this.activity.spot)
            .fontSize(12)
            .fontColor('#666')
            .margin({ left: 4 })
            .layoutWeight(1);

          Text(this.activity.participants)
            .fontSize(11)
            .fontColor('#4CAF50')
            .backgroundColor('#E8F5E9')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 });
        }
        .width('100%');
      }
      .padding(12)
      .width(280)
      .backgroundColor('#FFFFFF')
      .borderRadius({ bottomLeft: 12, bottomRight: 12 });
    }
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 });
  }
}

// 子组件：新闻卡片（增强版）
@Component
struct NewsCard {
  @ObjectLink news: NewsItem;

  build() {
    Row({ space: 12 }) {
      Image(this.news.img)
        .width(100)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover);

      Column({ space: 6 }) {
        Row() {
          Text(this.news.tag)
            .fontSize(11)
            .fontColor('#4CAF50')
            .backgroundColor('#E8F5E9')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 });
          Blank();
          Text(this.news.date)
            .fontSize(12)
            .fontColor('#999');
        }
        .width('100%');

        Text(this.news.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%');

        Text(this.news.summary)
          .fontSize(13)
          .fontColor('#666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%');

        Text('来源：' + this.news.source)
          .fontSize(12)
          .fontColor('#999')
          .width('100%');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 });
  }
}

// 子组件：视频推荐卡片
@Component
struct VideoCard {
  title: string = '';
  duration: string = '';
  img: Resource = $r('app.media.icon');

  build() {
    Column({ space: 0 }) {
      Stack() {
        Image(this.img)
          .width(200)
          .height(120)
          .borderRadius(8)
          .objectFit(ImageFit.Cover);

        Row() {
          Image($r('app.media.ic_play')).width(24).height(24).fillColor('#fff');
          Text(this.duration)
            .fontSize(12)
            .fontColor('#fff')
            .margin({ left: 4 });
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('rgba(0,0,0,0.6)')
        .borderRadius(4)
        .position({ x: 8, y: 88 });
      };

      Text(this.title)
        .fontSize(14)
        .fontColor('#333')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(200)
        .margin({ top: 8 });
    }
    .width(200);
  }
}