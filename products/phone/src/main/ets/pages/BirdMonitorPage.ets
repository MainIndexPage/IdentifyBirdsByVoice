// BirdMonitorPage.ets
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

interface MonitorDevice {
  id: string
  name: string
  location: string
  status: 'online' | 'offline' | 'recording'
  lastActive: string
  todayCount: number
  image: Resource
}

interface DetectionRecord {
  id: string
  birdName: string
  confidence: number
  time: string
  image: Resource
  deviceName: string
}

interface NavItem {
  name: string
  icon: Resource
  route: string
}

@Entry
@Component
struct BirdMonitorPage {
  @State currentNavIndex: number = -1
  @State selectedDevice: string = 'device_1'
  @State isRecording: boolean = false
  @State showDeviceList: boolean = false
  @State detectionRecords: DetectionRecord[] = this.mockRecords()

  private navList: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '听音识鸟', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社群', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ]

  private devices: MonitorDevice[] = [
    {
      id: 'device_1',
      name: '西溪湿地一号机',
      location: '浙江杭州·西溪湿地',
      status: 'recording',
      lastActive: '刚刚',
      todayCount: 23,
      image: $r('app.media.monitor_1')
    },
    {
      id: 'device_2',
      name: '鄱阳湖观测点',
      location: '江西九江·鄱阳湖',
      status: 'online',
      lastActive: '2分钟前',
      todayCount: 156,
      image: $r('app.media.monitor_2')
    },
    {
      id: 'device_3',
      name: '青海湖鸟岛',
      location: '青海·青海湖',
      status: 'online',
      lastActive: '5分钟前',
      todayCount: 89,
      image: $r('app.media.monitor_3')
    },
    {
      id: 'device_4',
      name: '崇明东滩',
      location: '上海·崇明岛',
      status: 'offline',
      lastActive: '2小时前',
      todayCount: 0,
      image: $r('app.media.monitor_4')
    }
  ]

  private navClick(index: number) {
    if (index === this.currentNavIndex) return
    const target = this.navList[index].route
    router.replaceUrl({ url: target })
    this.currentNavIndex = index
  }

  /* 获取当前设备 */
  private getCurrentDevice(): MonitorDevice {
    return this.devices.find(d => d.id === this.selectedDevice) || this.devices[0]
  }

  /* 获取状态颜色 */
  private getStatusColor(status: string): string {
    switch (status) {
      case 'recording': return '#FF4444'
      case 'online': return '#4CAF50'
      case 'offline': return '#999999'
      default: return '#999999'
    }
  }

  /* 获取状态文字 */
  private getStatusText(status: string): string {
    switch (status) {
      case 'recording': return '识别中'
      case 'online': return '在线'
      case 'offline': return '离线'
      default: return '未知'
    }
  }

  build() {
    Column() {
      /* 顶部标题栏 */
      this.TopBar()

      /* 主内容区 */
      Scroll() {
        Column({ space: 12 }) {
          /* 监控画面区域 */
          this.MonitorView()

          /* 设备切换栏 */
          this.DeviceSelector()

          /* 实时识别记录 */
          this.DetectionList()

          /* 统计信息 */
          this.StatsCard()
        }
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      this.BottomBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0A0A0A')
  }

  /* -------------------- 顶部栏 -------------------- */
  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
        .onClick(() => {
          router.replaceUrl({ url: 'pages/HomePage' })
        })

      Text('鸟类实时监控')
        .fontSize(18)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      /* 录制按钮 */
      Stack() {
        Circle()
          .width(this.isRecording ? 48 : 40)
          .height(this.isRecording ? 48 : 40)
          .fill(this.isRecording ? '#FF4444' : 'rgba(255,255,255,0.2)')
          .animation({
            duration: 1000,
            iterations: -1,
            playMode: PlayMode.Alternate
          })

        Image($r('app.media.ic_record'))
          .width(20)
          .height(20)
          .fillColor('#FFFFFF')
      }
      .onClick(() => {
        this.isRecording = !this.isRecording
        promptAction.showToast({
          message: this.isRecording ? '开始录制' : '停止录制'
        })
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#1A1A1A')
  }

  /* -------------------- 监控画面 -------------------- */
  @Builder
  MonitorView() {
    Column() {
      /* 模拟监控画面 */
      Stack() {
        /* 背景图/视频流 */
        Image(this.getCurrentDevice().image)
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)

        /* 暗色遮罩 */
        Column()
          .width('100%')
          .height(220)
          .backgroundColor('rgba(0,0,0,0.2)')
          .borderRadius(12)

        /* 左上角状态标识 */
        Row({ space: 6 }) {
          Circle()
            .width(8)
            .height(8)
            .fill(this.getStatusColor(this.getCurrentDevice().status))
            .animation({
              duration: 800,
              iterations: this.getCurrentDevice().status === 'recording' ? -1 : 0,
              playMode: PlayMode.Alternate
            })
            .opacity(this.getCurrentDevice().status === 'recording' ? 0.3 : 1)

          Text(this.getStatusText(this.getCurrentDevice().status))
            .fontSize(12)
            .fontColor('#FFFFFF')
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('rgba(0,0,0,0.6)')
        .borderRadius(4)
        .position({ x: 12, y: 12 })

        /* 右上角时间 */
        Text(this.getCurrentTime())
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(0,0,0,0.6)')
          .borderRadius(4)
          .position({ x: '72%', y: 12 })

        /* 底部信息栏 */
        Column({ space: 4 }) {
          Text(this.getCurrentDevice().name)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)

          Text(this.getCurrentDevice().location)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.8)')
        }
        .width('100%')
        .padding(12)
        .alignItems(HorizontalAlign.Start)
        .position({ y: 164 })
        .backgroundColor('linearGradient(180deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.8) 100%)')
      }
      .width('100%')
      .height(220)
      .borderRadius(12)

      /* AI识别框 - 模拟 */
      if (this.getCurrentDevice().status === 'recording') {
        this.AiDetectionBox()
      }
    }
  }

  /* AI识别框动画 */
  @Builder
  AiDetectionBox() {
    Row() {
      Column({ space: 2 }) {
        Text('黑脸琵鹭')
          .fontSize(12)
        Text('置信度: 98.5%')
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.8)')
      }
      .padding(6)
      .backgroundColor('rgba(76,175,80,0.9)')
      .borderRadius(4)

      /* 扫描线动画 */
      Column()
        .width(120)
        .height(2)
        .backgroundColor('#4CAF50')
        .position({ y: 0 })
        .animation({
          duration: 2000,
          iterations: -1,
          playMode: PlayMode.Alternate,
          curve: Curve.Linear
        })
    }
    .width(120)
    .height(80)
    .border({ width: 2, color: '#4CAF50' })
    .borderRadius(4)
    .position({ x: '40%', y: 80 })
  }

  /* -------------------- 设备选择器 -------------------- */
  @Builder
  DeviceSelector() {
    Column({ space: 8 }) {
      Row() {
        Text('监控点位')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)

        Blank()

        Row({ space: 4 }) {
          Text('切换设备')
            .fontSize(12)
            .fontColor('#4CAF50')
          Image($r('app.media.ic_arrow_down'))
            .width(12)
            .height(12)
            .fillColor('#4CAF50')
            .rotate({ angle: this.showDeviceList ? 180 : 0 })
            .animation({ duration: 300 })
        }
        .onClick(() => {
          this.showDeviceList = !this.showDeviceList
        })
      }
      .width('100%')

      /* 设备列表 */
      if (this.showDeviceList) {
        Column({ space: 8 }) {
          ForEach(this.devices, (device: MonitorDevice) => {
            Row({ space: 12 }) {
              /* 缩略图 */
              Stack() {
                Image(device.image)
                  .width(60)
                  .height(45)
                  .borderRadius(6)
                  .objectFit(ImageFit.Cover)

                if (device.status === 'offline') {
                  Column()
                    .width(60)
                    .height(45)
                    .backgroundColor('rgba(0,0,0,0.5)')
                    .borderRadius(6)
                }
              }

              Column({ space: 4 }) {
                Text(device.name)
                  .fontSize(13)
                  .fontColor(this.selectedDevice === device.id ? '#4CAF50' : '#FFFFFF')
                  .fontWeight(this.selectedDevice === device.id ? FontWeight.Medium : FontWeight.Normal)

                Text(device.location)
                  .fontSize(11)
                  .fontColor('#999999')

                Row({ space: 6 }) {
                  Circle()
                    .width(6)
                    .height(6)
                    .fill(this.getStatusColor(device.status))

                  Text(`${this.getStatusText(device.status)} · 今日${device.todayCount}次识别`)
                    .fontSize(10)
                    .fontColor('#999999')
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              if (this.selectedDevice === device.id) {
                Image($r('app.media.ic_check'))
                  .width(16)
                  .height(16)
                  .fillColor('#4CAF50')
              }
            }
            .width('100%')
            .padding(8)
            .backgroundColor(this.selectedDevice === device.id ? 'rgba(76,175,80,0.1)' : 'rgba(255,255,255,0.05)')
            .borderRadius(8)
            .onClick(() => {
              this.selectedDevice = device.id
              this.showDeviceList = false
              promptAction.showToast({ message: `已切换至: ${device.name}` })
            })
          })
        }
        .width('100%')
        .padding(8)
        .backgroundColor('rgba(255,255,255,0.05)')
        .borderRadius(12)
        .animation({ duration: 300 })
      }

      /* 当前设备快捷信息 */
      Row({ space: 12 }) {
        ForEach(this.devices.slice(0, 3), (device: MonitorDevice) => {
          Column({ space: 4 }) {
            Stack() {
              Image(device.image)
                .width(80)
                .height(60)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
                .border({
                  width: this.selectedDevice === device.id ? 2 : 0,
                  color: '#4CAF50'
                })

              if (this.selectedDevice === device.id) {
                Column()
                  .width(80)
                  .height(60)
                  .backgroundColor('rgba(76,175,80,0.2)')
                  .borderRadius(8)
              }

              /* 状态点 */
              Circle()
                .width(8)
                .height(8)
                .fill(this.getStatusColor(device.status))
                .position({ x: 4, y: 4 })
                .border({ width: 1, color: '#000000' })
            }

            Text(device.name.replace(/观测点|号机|鸟岛/, ''))
              .fontSize(10)
              .fontColor(this.selectedDevice === device.id ? '#4CAF50' : '#999999')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .onClick(() => {
            if (this.selectedDevice !== device.id) {
              this.selectedDevice = device.id
              promptAction.showToast({ message: `已切换: ${device.name}` })
            }
          })
        })
      }
      .width('100%')
    }
  }

  /* -------------------- 识别记录列表 -------------------- */
  @Builder
  DetectionList() {
    Column({ space: 12 }) {
      Row() {
        Text('实时识别记录')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)

        Blank()

        Row({ space: 4 }) {
          /* 实时指示器 */
          Row({ space: 4 }) {
            Circle()
              .width(6)
              .height(6)
              .fill('#FF4444')
              .animation({
                duration: 1000,
                iterations: -1,
                playMode: PlayMode.Alternate
              })
              .opacity(0.3)

            Text('实时更新')
              .fontSize(11)
              .fontColor('#FF4444')
          }

          Text('查看全部')
            .fontSize(12)
            .fontColor('#4CAF50')
            .onClick(() => {
              promptAction.showToast({ message: '查看全部记录' })
            })
        }
      }
      .width('100%')

      /* 记录列表 */
      Column({ space: 8 }) {
        ForEach(this.detectionRecords.slice(0, 5), (record: DetectionRecord, index: number) => {
          Row({ space: 12 }) {
            /* 序号/时间 */
            Column() {
              Text(`${index + 1}`)
                .fontSize(14)
                .fontColor('#4CAF50')
                .fontWeight(FontWeight.Bold)
            }
            .width(24)

            /* 鸟类图片 */
            Image(record.image)
              .width(50)
              .height(50)
              .borderRadius(6)
              .objectFit(ImageFit.Cover)

            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(record.birdName)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)

                /* 置信度标签 */
                Text(`${record.confidence}%`)
                  .fontSize(10)
                  .fontColor(record.confidence > 90 ? '#4CAF50' : '#FFA726')
                  .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                  .backgroundColor(record.confidence > 90 ? 'rgba(76,175,80,0.2)' : 'rgba(255,167,38,0.2)')
                  .borderRadius(4)
              }

              Row({ space: 8 }) {
                Image($r('app.media.ic_location'))
                  .width(10)
                  .height(10)
                  .fillColor('#666666')

                Text(record.deviceName)
                  .fontSize(11)
                  .fontColor('#666666')

                Text('|')
                  .fontSize(11)
                  .fontColor('#444444')

                Text(record.time)
                  .fontSize(11)
                  .fontColor('#666666')
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            /* 查看按钮 */
            Image($r('app.media.ic_arrow_right'))
              .width(16)
              .height(16)
              .fillColor('#666666')
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/BirdDetail',
                  params: { birdId: record.id }
                })
              })
          }
          .width('100%')
          .padding(10)
          .backgroundColor('rgba(255,255,255,0.05)')
          .borderRadius(8)
        })
      }
      .width('100%')
    }
  }

  /* -------------------- 统计卡片 -------------------- */
  @Builder
  StatsCard() {
    Column({ space: 12 }) {
      Text('今日监测统计')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .width('100%')

      Row({ space: 12 }) {
        /* 识别总数 */
        Column({ space: 4 }) {
          Text('156')
            .fontSize(28)
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Bold)

          Text('识别总数')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('rgba(76,175,80,0.1)')
        .borderRadius(12)

        /* 物种数 */
        Column({ space: 4 }) {
          Text('23')
            .fontSize(28)
            .fontColor('#2196F3')
            .fontWeight(FontWeight.Bold)

          Text('物种数量')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('rgba(33,150,243,0.1)')
        .borderRadius(12)

        /* 在线设备 */
        Column({ space: 4 }) {
          Text('3/4')
            .fontSize(28)
            .fontColor('#FF9800')
            .fontWeight(FontWeight.Bold)

          Text('在线设备')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('rgba(255,152,0,0.1)')
        .borderRadius(12)
      }
      .width('100%')

      /* 时段分布图 - 简化版 */
      Column({ space: 8 }) {
        Text('识别时段分布')
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')

        Row({ space: 4 }) {
          ForEach([30, 45, 80, 120, 90, 60, 40, 35, 50, 70, 85, 60], (value: number, index: number) => {
            Column() {
              Column()
                .width('100%')
                .height(value * 0.8)
                .backgroundColor(index === 3 ? '#4CAF50' : 'rgba(76,175,80,0.3)')
                .borderRadius(2)
            }
            .layoutWeight(1)
            .height(100)
            .justifyContent(FlexAlign.End)
          })
        }
        .width('100%')
        .height(100)

        Row() {
          ForEach(['6:00', '9:00', '12:00', '15:00', '18:00'], (time: string) => {
            Text(time)
              .fontSize(10)
              .fontColor('#666666')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          })
        }
        .width('100%')
      }
      .padding(12)
      .backgroundColor('rgba(255,255,255,0.05)')
      .borderRadius(12)
    }
    .width('100%')
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
            .fillColor(this.currentNavIndex === idx ? '#4CAF50' : '#666666')

          Text(item.name)
            .fontSize(10)
            .fontColor(this.currentNavIndex === idx ? '#4CAF50' : '#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => this.navClick(idx))
      })
    }
    .width('100%')
    .height(56)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#1A1A1A')
    .border({ width: { top: 1 }, color: '#333333' })
  }

  /* -------------------- 工具方法 -------------------- */
  private getCurrentTime(): string {
    const now = new Date()
    const hours = now.getHours().toString().padStart(2, '0')
    const minutes = now.getMinutes().toString().padStart(2, '0')
    const seconds = now.getSeconds().toString().padStart(2, '0')
    return `${hours}:${minutes}:${seconds}`
  }

  private mockRecords(): DetectionRecord[] {
    return [
      {
        id: '1',
        birdName: '黑脸琵鹭',
        confidence: 98.5,
        time: '10:23:45',
        image: $r('app.media.Platalea_minor'),
        deviceName: '西溪湿地一号机'
      },
      {
        id: '2',
        birdName: '普通翠鸟',
        confidence: 95.2,
        time: '10:18:32',
        image: $r('app.media.Alcedo_atthis'),
        deviceName: '西溪湿地一号机'
      },
      {
        id: '3',
        birdName: '红嘴蓝鹊',
        confidence: 97.8,
        time: '09:56:12',
        image: $r('app.media.Urocissa_erythroryncha'),
        deviceName: '鄱阳湖观测点'
      },
      {
        id: '4',
        birdName: '东方白鹳',
        confidence: 99.1,
        time: '09:42:08',
        image: $r('app.media.Ciconia_boyciana'),
        deviceName: '鄱阳湖观测点'
      },
      {
        id: '5',
        birdName: '黑颈鹤',
        confidence: 96.4,
        time: '08:35:27',
        image: $r('app.media.Grus_nigricollis'),
        deviceName: '青海湖鸟岛'
      },
      {
        id: '6',
        birdName: '大天鹅',
        confidence: 94.7,
        time: '08:12:15',
        image: $r('app.media.Cygnus_cygnus'),
        deviceName: '青海湖鸟岛'
      },
      {
        id: '7',
        birdName: '中华秋沙鸭',
        confidence: 93.5,
        time: '07:48:56',
        image: $r('app.media.Mergus_squamatus'),
        deviceName: '西溪湿地一号机'
      }
    ]
  }
}