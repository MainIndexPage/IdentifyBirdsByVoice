import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

interface Foundation {
  id: string
  name: string
  logo: Resource
  established: string
  focus: string
  projects: number
  raised: string
  rating: number
  status: '认证' | '未认证'
  description: string
  website: string
}

interface NavItem {
  name: string
  icon: Resource
  route: string
}

@Entry
@Component
struct BirdCharityPage {
  @State currentNavIndex: number = 0
  @State searchKeyword: string = ''
  @State selectedRegion: string = '全部地区'
  @State selectedFocus: string = '全部领域'
  @State showFilterPanel: boolean = false
  @State selectedFoundation: string = ''
  @State donationAmount: number = 50
  @State showDonationDialog: boolean = false
  @State currentFoundation: Foundation | null = null

  private navList: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '监控', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '公益', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ]

  private regions: string[] = ['全部地区', '北京', '上海', '广东', '浙江', '江苏', '云南', '四川', '湖北', '国际']
  private focusAreas: string[] = ['全部领域', '候鸟保护', '湿地修复', '濒危物种', '科普教育', '反盗猎', '栖息地保护']

  @State foundations: Foundation[] = [
    {
      id: '1',
      name: '中国观鸟会',
      logo: $r('app.media.logo_cba'),
      established: '2004年',
      focus: '科普教育',
      projects: 156,
      raised: '2,380万',
      rating: 4.9,
      status: '认证',
      description: '致力于中国野生鸟类研究与保护，开展全国性鸟类调查与科普活动',
      website: 'www.chinabird.org'
    },
    {
      id: '2',
      name: '红树林基金会',
      logo: $r('app.media.logo_mcf'),
      established: '2012年',
      focus: '湿地修复',
      projects: 89,
      raised: '5,600万',
      rating: 4.8,
      status: '认证',
      description: '专注滨海湿地保护，修复红树林生态系统，保护水鸟栖息地',
      website: 'www.mcf.org.cn'
    },
    {
      id: '3',
      name: '阿拉善SEE基金会',
      logo: $r('app.media.logo_see'),
      established: '2008年',
      focus: '栖息地保护',
      projects: 234,
      raised: '1.2亿',
      rating: 4.9,
      status: '认证',
      description: '企业家联合发起，聚焦荒漠化防治与生物多样性保护',
      website: 'www.see.org.cn'
    },
    {
      id: '4',
      name: '国际鹤类基金会',
      logo: $r('app.media.logo_icf'),
      established: '1973年',
      focus: '濒危物种',
      projects: 45,
      raised: '8,900万',
      rating: 4.7,
      status: '认证',
      description: '全球鹤类保护权威机构，在中国开展黑颈鹤、丹顶鹤保护项目',
      website: 'www.savingcranes.org'
    },
    {
      id: '5',
      name: '山水自然保护中心',
      logo: $r('app.media.logo_shanshui'),
      established: '2007年',
      focus: '反盗猎',
      projects: 78,
      raised: '3,200万',
      rating: 4.8,
      status: '认证',
      description: '保护西南山地的濒危物种和生态系统，打击非法野生动物贸易',
      website: 'www.shanshui.org'
    },

    {
      id: '6',
      name: '世界自然基金会',
      logo: $r('app.media.logo_wwf'),
      established: '1961年',
      focus: '濒危物种',
      projects: 312,
      raised: '3.5亿',
      rating: 4.9,
      status: '认证',
      description: '全球最大独立性自然保护组织，在中国开展长江江豚、东北虎等项目',
      website: 'www.wwfchina.org'
    }
  ]

  /* 筛选后的基金会列表 */
  private getFilteredFoundations(): Foundation[] {
    return this.foundations.filter(f => {
      const matchRegion = this.selectedRegion === '全部地区' ||
      f.description.includes(this.selectedRegion) ||
      f.name.includes(this.selectedRegion)
      const matchFocus = this.selectedFocus === '全部领域' || f.focus === this.selectedFocus
      const matchSearch = this.searchKeyword === '' ||
      f.name.includes(this.searchKeyword) ||
      f.description.includes(this.searchKeyword)
      return matchRegion && matchFocus && matchSearch
    })
  }

  private navClick(index: number) {
    if (index === this.currentNavIndex) return
    const target = this.navList[index].route
    router.replaceUrl({ url: target })
    this.currentNavIndex = index
  }

  private openDonation(foundation: Foundation) {
    this.currentFoundation = foundation
    this.donationAmount = 50
    this.showDonationDialog = true
  }

  private confirmDonation() {
    if (!this.currentFoundation) return
    promptAction.showToast({
      message: `已向"${this.currentFoundation.name}"捐赠¥${this.donationAmount}`
    })
    this.showDonationDialog = false
    this.currentFoundation = null
  }

  build() {
    Column() {
      /* 顶部栏 */
      this.TopBar()

      /* 搜索和筛选 */
      this.SearchFilterBar()

      /* 筛选面板 */
      if (this.showFilterPanel) {
        this.FilterPanel()
      }

      /* 统计信息 */
      this.StatsBar()

      /* 基金会表格列表 */
      List({ space: 12 }) {
        ForEach(this.getFilteredFoundations(), (foundation: Foundation) => {
          ListItem() {
            this.FoundationCard(foundation)
          }
        })
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .scrollBar(BarState.Off)

      this.BottomBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
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
          router.replaceUrl({ url: 'pages/HomePage' })
        })

      Text('鸟类公益')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Image($r('app.media.ic_more'))
        .width(24)
        .height(24)
        .fillColor('#333')
        .onClick(() => {
          promptAction.showToast({ message: '更多功能开发中' })
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  /* -------------------- 搜索筛选栏 -------------------- */
  @Builder
  SearchFilterBar() {
    Column({ space: 12 }) {
      /* 搜索框 */
      Row({ space: 8 }) {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .fillColor('#999')

        TextInput({ placeholder: '搜索基金会名称...', text: this.searchKeyword })
          .placeholderColor('#999')
          .fontSize(14)
          .height(40)
          .backgroundColor('transparent')
          .layoutWeight(1)
          .onChange((value) => {
            this.searchKeyword = value
          })

        if (this.searchKeyword !== '') {
          Image($r('app.media.ic_clear'))
            .width(18)
            .height(18)
            .fillColor('#999')
            .onClick(() => {
              this.searchKeyword = ''
            })
        }
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(22)

      /* 快捷筛选标签 */
      Row({ space: 8 }) {
        /* 地区筛选 */
        Row({ space: 4 }) {
          Text(this.selectedRegion)
            .fontSize(12)
            .fontColor(this.selectedRegion !== '全部地区' ? '#4CAF50' : '#666')
          Image($r('app.media.ic_arrow_down'))
            .width(12)
            .height(12)
            .fillColor(this.selectedRegion !== '全部地区' ? '#4CAF50' : '#666')
            .rotate({ angle: this.showFilterPanel ? 180 : 0 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.selectedRegion !== '全部地区' ? '#E8F5E9' : '#FFFFFF')
        .borderRadius(16)
        .onClick(() => {
          this.showFilterPanel = !this.showFilterPanel
        })

        /* 领域筛选 */
        Row({ space: 4 }) {
          Text(this.selectedFocus)
            .fontSize(12)
            .fontColor(this.selectedFocus !== '全部领域' ? '#2196F3' : '#666')
          Image($r('app.media.ic_arrow_down'))
            .width(12)
            .height(12)
            .fillColor(this.selectedFocus !== '全部领域' ? '#2196F3' : '#666')
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.selectedFocus !== '全部领域' ? '#E3F2FD' : '#FFFFFF')
        .borderRadius(16)
        .onClick(() => {
          this.showFilterPanel = !this.showFilterPanel
        })

        Blank()

        /* 排序按钮 */
        Row({ space: 4 }) {
          Image($r('app.media.ic_sort'))
            .width(14)
            .height(14)
            .fillColor('#666')
          Text('排序')
            .fontSize(12)
            .fontColor('#666')
        }
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F5F5F5')
  }

  /* -------------------- 筛选面板 -------------------- */
  @Builder
  FilterPanel() {
    Column({ space: 16 }) {
      /* 地区选择 */
      Column({ space: 8 }) {
        Text('地区')
          .fontSize(13)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.regions, (region: string) => {
            Text(region)
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin(4)
              .backgroundColor(this.selectedRegion === region ? '#4CAF50' : '#F0F0F0')
              .fontColor(this.selectedRegion === region ? '#FFFFFF' : '#666')
              .borderRadius(16)
              .onClick(() => {
                this.selectedRegion = region
              })
          })
        }
      }

      /* 领域选择 */
      Column({ space: 8 }) {
        Text('关注领域')
          .fontSize(13)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.focusAreas, (focus: string) => {
            Text(focus)
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin(4)
              .backgroundColor(this.selectedFocus === focus ? '#2196F3' : '#F0F0F0')
              .fontColor(this.selectedFocus === focus ? '#FFFFFF' : '#666')
              .borderRadius(16)
              .onClick(() => {
                this.selectedFocus = focus
              })
          })
        }
      }

      /* 重置按钮 */
      Button('重置筛选')
        .width('100%')
        .height(36)
        .fontSize(13)
        .fontColor('#666')
        .backgroundColor('#F0F0F0')
        .onClick(() => {
          this.selectedRegion = '全部地区'
          this.selectedFocus = '全部领域'
          this.searchKeyword = ''
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: -8, bottom: 8 })
  }

  /* -------------------- 统计栏 -------------------- */
  @Builder
  StatsBar() {
    Row({ space: 16 }) {
      Column({ space: 2 }) {
        Text(`${this.foundations.length}`)
          .fontSize(20)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
        Text('合作基金会')
          .fontSize(11)
          .fontColor('#999')
      }

      Column({ space: 2 }) {
        Text('¥8.5亿+')
          .fontSize(20)
          .fontColor('#FF6B6B')
          .fontWeight(FontWeight.Bold)
        Text('累计筹款')
          .fontSize(11)
          .fontColor('#999')
      }

      Column({ space: 2 }) {
        Text('1,200+')
          .fontSize(20)
          .fontColor('#2196F3')
          .fontWeight(FontWeight.Bold)
        Text('保护项目')
          .fontSize(11)
          .fontColor('#999')
      }

      Column({ space: 2 }) {
        Text('50万+')
          .fontSize(20)
          .fontColor('#FFA726')
          .fontWeight(FontWeight.Bold)
        Text('捐赠人次')
          .fontSize(11)
          .fontColor('#999')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceAround)
  }

  /* -------------------- 基金会卡片 -------------------- */
  @Builder
  FoundationCard(foundation: Foundation) {
    Column({ space: 12 }) {
      /* 头部信息 */
      Row({ space: 12 }) {
        /* Logo */
        Stack() {
          Image(foundation.logo)
            .width(56)
            .height(56)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)

          /* 认证标识 */
          if (foundation.status === '认证') {
            Image($r('app.media.ic_verified'))
              .width(16)
              .height(16)
              .position({ x: 40, y: -4 })
          }
        }

        Column({ space: 4 }) {
          Row({ space: 6 }) {
            Text(foundation.name)
              .fontSize(16)
              .fontColor('#333')
              .fontWeight(FontWeight.Medium)

            Text(foundation.focus)
              .fontSize(10)
              .fontColor('#4CAF50')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#E8F5E9')
              .borderRadius(4)
          }

          Row({ space: 8 }) {
            Image($r('app.media.ic_star'))
              .width(12)
              .height(12)
              .fillColor('#FFA726')

            Text(`${foundation.rating}分`)
              .fontSize(12)
              .fontColor('#666')

            Text('|')
              .fontSize(12)
              .fontColor('#DDD')

            Text(`成立于${foundation.established}`)
              .fontSize(12)
              .fontColor('#999')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

      /* 数据指标 */
      Row({ space: 8 }) {
        this.StatItem('执行项目', `${foundation.projects}个`, '#4CAF50')
        this.StatItem('累计筹款', foundation.raised, '#FF6B6B')
        this.StatItem('官网', '访问', '#2196F3', () => {
          promptAction.showToast({ message: `访问: ${foundation.website}` })
        })
      }
      .width('100%')

      /* 简介 */
      Text(foundation.description)
        .fontSize(12)
        .fontColor('#666')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      /* 操作按钮 */
      Row({ space: 8 }) {
        Button('了解详情')
          .width('50%')
          .height(36)
          .fontSize(13)
          .fontColor('#666')
          .backgroundColor('#F5F5F5')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/FoundationDetail',
              params: { foundationId: foundation.id }
            })
          })

        Button('立即捐赠')
          .width('50%')
          .height(36)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#4CAF50')
          .onClick(() => {
            this.openDonation(foundation)
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  StatItem(label: string, value: string, color: string, onClick?: () => void) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(14)
        .fontColor(color)
        .fontWeight(FontWeight.Medium)

      Text(label)
        .fontSize(10)
        .fontColor('#999')
    }
    .layoutWeight(1)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#F8F8F8')
    .borderRadius(6)
    .onClick(() => {
      if (onClick) onClick()
    })
  }

  /* -------------------- 捐赠弹窗 -------------------- */
  @Builder
  DonationDialog() {
    if (this.showDonationDialog && this.currentFoundation) {
      Column() {
        /* 遮罩层 */
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.6)')
          .onClick(() => {
            this.showDonationDialog = false
          })

        /* 弹窗内容 */
        Column({ space: 16 }) {
          /* 关闭按钮 */
          Row() {
            Blank()
            Image($r('app.media.ic_close'))
              .width(20)
              .height(20)
              .fillColor('#999')
              .onClick(() => {
                this.showDonationDialog = false
              })
          }
          .width('100%')

          /* 基金会信息 */
          Image(this.currentFoundation.logo)
            .width(64)
            .height(64)
            .borderRadius(12)

          Text(this.currentFoundation.name)
            .fontSize(16)
            .fontColor('#333')
            .fontWeight(FontWeight.Medium)

          Text('您的捐赠将用于鸟类保护事业')
            .fontSize(12)
            .fontColor('#999')

          /* 金额选择 */
          Text('选择捐赠金额')
            .fontSize(14)
            .fontColor('#333')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)

          Row({ space: 8 }) {
            ForEach([10, 30, 50, 100, 200], (amount: number) => {
              Column() {
                Text(`¥${amount}`)
                  .fontSize(14)
                  .fontColor(this.donationAmount === amount ? '#FFFFFF' : '#333')
              }
              .width('18%')
              .height(40)
              .backgroundColor(this.donationAmount === amount ? '#4CAF50' : '#F5F5F5')
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.donationAmount = amount
              })
            })
          }
          .width('100%')

          /* 自定义金额 */
          TextInput({ placeholder: '自定义金额' })
            .width('100%')
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .type(InputType.Number)
            .onChange((value) => {
              if (value) {
                this.donationAmount = parseInt(value)
              }
            })

          /* 支付方式 */
          Text('支付方式')
            .fontSize(14)
            .fontColor('#333')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 8 })

          Row({ space: 12 }) {
            Row({ space: 6 }) {
              Image($r('app.media.ic_alipay'))
                .width(20)
                .height(20)
              Text('支付宝')
                .fontSize(12)
                .fontColor('#333')
            }
            .layoutWeight(1)
            .height(40)
            .padding({ left: 12 })
            .backgroundColor('#E8F5E9')
            .borderRadius(8)

            Row({ space: 6 }) {
              Image($r('app.media.ic_wechat'))
                .width(20)
                .height(20)
              Text('微信支付')
                .fontSize(12)
                .fontColor('#333')
            }
            .layoutWeight(1)
            .height(40)
            .padding({ left: 12 })
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
          }
          .width('100%')

          /* 确认按钮 */
          Button(`确认捐赠 ¥${this.donationAmount}`)
            .width('100%')
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(22)
            .onClick(() => {
              this.confirmDonation()
            })

          Text('捐赠即表示同意《公益捐赠协议》')
            .fontSize(11)
            .fontColor('#999')
        }
        .width('85%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .position({ x: '7.5%', y: '15%' })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
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
}