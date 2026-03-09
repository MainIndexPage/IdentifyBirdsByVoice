// VolunteerApplicationPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 志愿者项目数据接口
interface VolunteerProject {
  id: string;
  role: string;
  req: string;
  location: string;
  time: string;
  spots: number;
  img: Resource;
  description: string;
  contact: string;
}

// 底部导航项接口
interface NavItem {
  name: string;
  icon: Resource;
  route: string;
}

@Entry
@Component
struct VolunteerApplicationPage {
  // 底部导航默认不选中
  @State currentNavIndex: number = -1;
  // 搜索关键词
  @State searchKeyword: string = '';
  // 筛选条件
  @State selectedTime: string = '全部时间';
  @State showFilterPanel: boolean = false;
  // 申请弹窗相关
  @State showApplyDialog: boolean = false;
  @State currentProject: VolunteerProject | null = null;
  @State applicantName: string = '';
  @State applicantPhone: string = '';
  @State applicantRemark: string = '';

  // 底部导航配置
  private navList: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '听音识鸟', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社群', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ];

  // 时间筛选选项
  private timeOptions: string[] = ['全部时间', '周末', '工作日', '候鸟季(3-5月)'];

  // 模拟志愿者项目数据
  @State projects: VolunteerProject[] = [
    {
      id: '1',
      role: '周末湿地巡护',
      req: '每月 2 次，提供保险与培训',
      location: '崇明东滩湿地',
      time: '每周六 08:00-12:00',
      spots: 15,
      img: $r('app.media.news_dongtan'),
      description: '协助工作人员进行湿地巡护，记录鸟类活动，清理垃圾。需要有较好的体力，能适应户外环境。',
      contact: '张老师 138-xxxx-xxxx'
    },
    {
      id: '2',
      role: '鸟类环志助理',
      req: '需体力好，候鸟季 3-5 月',
      location: '南汇嘴观海公园',
      time: '3月-5月 全天',
      spots: 8,
      img: $r('app.media.news_owl'),
      description: '协助专业人员进行候鸟环志工作，包括捕捉、测量、记录、放飞等环节。需连续参与一周以上。',
      contact: '李老师 139-xxxx-xxxx'
    },
    {
      id: '3',
      role: '科普讲解志愿者',
      req: '周末在博物馆为小朋友讲解',
      location: '上海自然博物馆',
      time: '每周日 10:00-16:00',
      spots: 10,
      img: $r('app.media.news_discovery'),
      description: '为参观的小朋友和家长讲解鸟类知识，引导正确的观鸟理念。需要有亲和力，善于表达。',
      contact: '王老师 137-xxxx-xxxx'
    },
    {
      id: '4',
      role: '社区宣传专员',
      req: '擅长沟通，有文案或设计经验优先',
      location: '各社区居委会',
      time: '工作日晚间',
      spots: 20,
      img: $r('app.media.img_donate_banner'),
      description: '进入社区进行鸟类保护知识宣传，布置展板，发放手册。',
      contact: '刘老师 136-xxxx-xxxx'
    }
  ];

  // 筛选后的项目列表
  private getFilteredProjects(): VolunteerProject[] {
    return this.projects.filter(p => {
      const matchTime = this.selectedTime === '全部时间' || p.time.includes(this.selectedTime);
      const matchSearch = this.searchKeyword === '' ||
      p.role.includes(this.searchKeyword) ||
      p.description.includes(this.searchKeyword) ||
      p.location.includes(this.searchKeyword);
      return matchTime && matchSearch;
    });
  }

  // 底部导航点击
  private navClick(index: number) {
    if (index === this.currentNavIndex) return;
    const target = this.navList[index].route;
    router.replaceUrl({ url: target });
    this.currentNavIndex = index;
  }

  // 打开申请弹窗
  private openApplyDialog(project: VolunteerProject) {
    this.currentProject = project;
    this.applicantName = '';
    this.applicantPhone = '';
    this.applicantRemark = '';
    this.showApplyDialog = true;
  }

  // 提交申请
  private submitApplication() {
    if (!this.currentProject) return;
    if (!this.applicantName || !this.applicantPhone) {
      promptAction.showToast({ message: '请填写姓名和联系方式' });
      return;
    }
    promptAction.showToast({
      message: `已成功申请"${this.currentProject.role}"，请保持电话畅通`
    });
    this.showApplyDialog = false;
    this.currentProject = null;
  }

  build() {
    Column() {
      // 1. 顶部栏
      this.TopBar();

      // 2. 搜索和筛选
      this.SearchFilterBar();

      // 3. 筛选面板
      if (this.showFilterPanel) {
        this.FilterPanel();
      }

      // 4. 项目列表
      List({ space: 12 }) {
        ForEach(this.getFilteredProjects(), (project: VolunteerProject) => {
          ListItem() {
            this.ProjectCard(project);
          }
        });
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .scrollBar(BarState.Off);

      // 5. 底部导航栏
      this.BottomBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  /* -------------------- 顶部栏 -------------------- */
  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333')
        .onClick(() => {
          router.replaceUrl({ url: 'pages/BirdPublicWelfarePage' });
        });

      Text('志愿者申请')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center);

      Image($r('app.media.ic_more'))
        .width(24)
        .height(24)
        .fillColor('#333')
        .onClick(() => {
          promptAction.showToast({ message: '更多功能开发中' });
        });
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF');
  }

  /* -------------------- 搜索筛选栏 -------------------- */
  @Builder
  SearchFilterBar() {
    Column({ space: 12 }) {
      // 搜索框
      Row({ space: 8 }) {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .fillColor('#999');

        TextInput({ placeholder: '搜索岗位、地点...', text: this.searchKeyword })
          .placeholderColor('#999')
          .fontSize(14)
          .height(40)
          .backgroundColor('transparent')
          .layoutWeight(1)
          .onChange((value) => {
            this.searchKeyword = value;
          });

        if (this.searchKeyword !== '') {
          Image($r('app.media.ic_clear'))
            .width(18)
            .height(18)
            .fillColor('#999')
            .onClick(() => {
              this.searchKeyword = '';
            });
        }
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(22);

      // 快捷筛选标签
      Row({ space: 8 }) {
        // 时间筛选
        Row({ space: 4 }) {
          Text(this.selectedTime)
            .fontSize(12)
            .fontColor(this.selectedTime !== '全部时间' ? '#4CAF50' : '#666');
          Image($r('app.media.ic_arrow_down'))
            .width(12)
            .height(12)
            .fillColor(this.selectedTime !== '全部时间' ? '#4CAF50' : '#666')
            .rotate({ angle: this.showFilterPanel ? 180 : 0 });
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.selectedTime !== '全部时间' ? '#E8F5E9' : '#FFFFFF')
        .borderRadius(16)
        .onClick(() => {
          this.showFilterPanel = !this.showFilterPanel;
        });

        Blank();
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F5F5F5');
  }

  /* -------------------- 筛选面板 -------------------- */
  @Builder
  FilterPanel() {
    Column({ space: 16 }) {
      // 时间选择
      Column({ space: 8 }) {
        Text('服务时间')
          .fontSize(13)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
          .width('100%');

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.timeOptions, (time: string) => {
            Text(time)
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin(4)
              .backgroundColor(this.selectedTime === time ? '#4CAF50' : '#F0F0F0')
              .fontColor(this.selectedTime === time ? '#FFFFFF' : '#666')
              .borderRadius(16)
              .onClick(() => {
                this.selectedTime = time;
              });
          });
        }
      }

      // 重置按钮
      Button('重置筛选')
        .width('100%')
        .height(36)
        .fontSize(13)
        .fontColor('#666')
        .backgroundColor('#F0F0F0')
        .onClick(() => {
          this.selectedTime = '全部时间';
          this.searchKeyword = '';
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: -8, bottom: 8 });
  }

  /* -------------------- 项目卡片 -------------------- */
  @Builder
  ProjectCard(project: VolunteerProject) {
    Column({ space: 12 }) {
      // 图片和标题
      Stack() {
        Image(project.img)
          .width('100%')
          .height(140)
          .borderRadius(12)
          .objectFit(ImageFit.Cover);

        Column() {
          Blank();
          Row() {
            Text(project.role)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff');
            Blank();
          }
          .width('100%');
        }
        .padding(12)
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.3)')
        .borderRadius(12);
      }
      .width('100%')
      .height(140);

      // 基本信息
      Row({ space: 12 }) {
        this.InfoItem($r('app.media.ic_location'), project.location, '#666');
        this.InfoItem($r('app.media.ic_time'), project.time, '#666');
      }
      .width('100%');

      // 要求
      Text(project.req)
        .fontSize(13)
        .fontColor('#4CAF50')
        .width('100%')
        .padding(10)
        .backgroundColor('#E8F5E9')
        .borderRadius(8);

      // 描述
      Text(project.description)
        .fontSize(13)
        .fontColor('#666')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%');

      // 底部信息和按钮
      Row() {
        Column({ space: 2 }) {
          Text(`剩余名额: ${project.spots}人`)
            .fontSize(12)
            .fontColor('#FF6B6B');
          Text(project.contact)
            .fontSize(11)
            .fontColor('#999');
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Button('立即申请')
          .width(100)
          .height(36)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#4CAF50')
          .onClick(() => {
            this.openApplyDialog(project);
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12);
  }

  @Builder
  InfoItem(icon: Resource, text: string, color: string) {
    Row({ space: 4 }) {
      Image(icon)
        .width(14)
        .height(14)
        .fillColor(color);
      Text(text)
        .fontSize(12)
        .fontColor(color);
    }
  }

  /* -------------------- 申请弹窗 -------------------- */
  @Builder
  ApplyDialog() {
    if (this.showApplyDialog && this.currentProject) {
      Column() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.6)')
          .onClick(() => {
            this.showApplyDialog = false;
          });

        // 弹窗内容
        Column({ space: 16 }) {
          // 关闭按钮
          Row() {
            Blank();
            Image($r('app.media.ic_close'))
              .width(20)
              .height(20)
              .fillColor('#999')
              .onClick(() => {
                this.showApplyDialog = false;
              });
          }
          .width('100%');

          // 项目信息
          Text(this.currentProject.role)
            .fontSize(18)
            .fontColor('#333')
            .fontWeight(FontWeight.Bold);

          Text(this.currentProject.location + ' | ' + this.currentProject.time)
            .fontSize(12)
            .fontColor('#999');

          // 表单
          Column({ space: 12 }) {
            TextInput({ placeholder: '请输入您的姓名', text: this.applicantName })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value) => {
                this.applicantName = value;
              });

            TextInput({ placeholder: '请输入联系电话', text: this.applicantPhone })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .type(InputType.PhoneNumber)
              .onChange((value) => {
                this.applicantPhone = value;
              });

            TextArea({ placeholder: '备注信息（可选）', text: this.applicantRemark })
              .width('100%')
              .height(80)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value) => {
                this.applicantRemark = value;
              });
          }
          .margin({ top: 8 });

          // 确认按钮
          Button('提交申请')
            .width('100%')
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(22)
            .onClick(() => {
              this.submitApplication();
            });
        }
        .width('85%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .position({ x: '7.5%', y: '10%' });
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 });
    }
  }

  /* -------------------- 底部导航 -------------------- */
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
        .onClick(() => this.navClick(idx));
      });
    }
    .width('100%')
    .height(56)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#E0E0E0' });
  }
}