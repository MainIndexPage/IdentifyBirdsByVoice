import router from '@ohos.router'
import hilog from '@ohos.hilog'
import promptAction from '@ohos.promptAction'
import picker from '@ohos.file.picker'
import { BusinessError } from '@ohos.base'
import { http } from '@kit.NetworkKit'
import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit'
import { geoLocationManager } from '@kit.LocationKit'
import { fileIo } from '@kit.CoreFileKit'
import { AudioCapture } from '../utils/AudioCapture'
import { BirdApiItem, BirdBackendService, mapPosterResource } from '../services/BirdBackendService'

interface NavItem {
  name: string
  icon: Resource
  route: string
}

interface BirdResult {
  bird_name: string
  confidence: number
  label_id: number
}

interface BackendResponse {
  code: number
  msg: string
  data: BirdResult[]
}

interface RecognitionFallbackBird {
  recognitionLabel: string
  birdNameZh: string
  birdNameLatin: string
  birdFamily: string
  birdHabitat: string
  birdProtection: string
  birdPoster: string
  birdDistribution: string
  birdLivingHabits: string
  birdBreeding: string
  birdIntro: string
}

interface RecognitionLocation {
  latitude: number
  longitude: number
  locationName: string
}

@Entry
@Component
struct BirdSoundRecognitionPage {
  @State private isRecording: boolean = false
  @State private isRecognizing: boolean = false
  @State private recordedFilePath: string = ''
  @State private resultText: string = '请先录制鸟类声音或上传音频文件。'
  @State private recordBtnText: string = '开始录音'
  @State private currentNavIndex: number = 2
  @State private resultDescription: string = ''
  @State private currentBirdImage: Resource | null = null
  @State private matchedBirdId: number = -1

  private navItems: NavItem[] = [
    { name: '首页', icon: $r('app.media.nav_home'), route: 'pages/HomePage' },
    { name: '图鉴', icon: $r('app.media.nav_encyclopedia'), route: 'pages/BirdGallery' },
    { name: '听声识鸟', icon: $r('app.media.nav_listen'), route: 'pages/BirdSoundRecognitionPage' },
    { name: '社区', icon: $r('app.media.nav_community'), route: 'pages/BirdShare' },
    { name: '我的', icon: $r('app.media.nav_profile'), route: 'pages/ProfilePage' }
  ]

  private readonly SERVER_URL: string = 'http://10.0.2.2:8000/api/bird/recognize'

  private readonly FALLBACK_BIRDS: RecognitionFallbackBird[] = [
    {
      recognitionLabel: 'Pseudocolopteryx acutipennis_Subtropical Doradito',
      birdNameZh: '亚热带多拉迪鹩霸鹟',
      birdNameLatin: 'Pseudocolopteryx acutipennis',
      birdFamily: '霸鹟科',
      birdHabitat: '常见于亚热带湿地、灌丛与水边低矮植被区',
      birdProtection: '暂无资料',
      birdPoster: 'Pseudocolopteryx_acutipennis_Subtropical_Doradito',
      birdDistribution: '主要分布于南美洲',
      birdLivingHabits: '多停留在湿地边缘低矮植被中活动，鸣声细密。',
      birdBreeding: '暂无详细繁殖资料，可后续补充。',
      birdIntro: '亚热带多拉迪鹩霸鹟是一种小型鸣禽，常在湿地周边活动。'
    },
    {
      recognitionLabel: 'Mellisuga helenae_Bee Hummingbird',
      birdNameZh: '吸蜜蜂鸟',
      birdNameLatin: 'Mellisuga helenae',
      birdFamily: '蜂鸟科',
      birdHabitat: '热带灌丛、花园与花蜜资源丰富的林缘地带',
      birdProtection: '暂无资料',
      birdPoster: 'Mellisuga_helenae_Bee_Hummingbird',
      birdDistribution: '主要分布于古巴',
      birdLivingHabits: '体型极小，常悬停采食花蜜，也会捕食微小昆虫。',
      birdBreeding: '暂无详细繁殖资料，可后续补充。',
      birdIntro: '吸蜜蜂鸟是现存最小的鸟类之一，以灵巧的飞行著称。'
    }
  ]

  aboutToAppear(): void {
    hilog.info(0x0000, 'BirdSoundRecognitionPage', 'page appear')
  }

  aboutToDisappear(): void {
    AudioCapture.release()
  }

  private stringToArrayBuffer(str: string): ArrayBuffer {
    const buffer: ArrayBuffer = new ArrayBuffer(str.length)
    const view: Uint8Array = new Uint8Array(buffer)
    for (let i: number = 0; i < str.length; i++) {
      view[i] = str.charCodeAt(i)
    }
    return buffer
  }

  private normalizeMatchText(text: string): string {
    return text.toLowerCase().replace(/[_\-]+/g, ' ').replace(/\s+/g, ' ').trim()
  }

  private splitRecognitionLabel(label: string): string[] {
    const values: string[] = [label]
    const separatorIndex: number = label.indexOf('_')
    if (separatorIndex >= 0) {
      values.push(label.substring(0, separatorIndex))
      values.push(label.substring(separatorIndex + 1))
    }
    return values.map((item: string) => item.trim()).filter((item: string) => item.length > 0)
  }

  private buildBirdDescriptionFromApi(item: BirdApiItem): string {
    const sections: string[] = []
    if (item.birdIntro.trim().length > 0) sections.push(item.birdIntro.trim())
    if (item.birdFamily.trim().length > 0) sections.push(`科属：${item.birdFamily.trim()}`)
    if (item.birdHabitat.trim().length > 0) sections.push(`栖息地：${item.birdHabitat.trim()}`)
    if (item.birdDistribution.trim().length > 0) sections.push(`分布：${item.birdDistribution.trim()}`)
    if (item.birdLivingHabits.trim().length > 0) sections.push(`生活习性：${item.birdLivingHabits.trim()}`)
    if (item.birdBreeding.trim().length > 0) sections.push(`繁殖：${item.birdBreeding.trim()}`)
    return sections.join('\n')
  }

  private buildBirdDescriptionFromFallback(item: RecognitionFallbackBird): string {
    return [
      item.birdIntro,
      `科属：${item.birdFamily}`,
      `栖息地：${item.birdHabitat}`,
      `分布：${item.birdDistribution}`,
      `生活习性：${item.birdLivingHabits}`,
      `繁殖：${item.birdBreeding}`
    ].join('\n')
  }

  private matchBirdFromDatabase(recognitionLabel: string, birds: BirdApiItem[]): BirdApiItem | null {
    const candidates: string[] = this.splitRecognitionLabel(recognitionLabel)
      .map((item: string) => this.normalizeMatchText(item))

    for (let i: number = 0; i < birds.length; i++) {
      const bird: BirdApiItem = birds[i]
      const values: string[] = [bird.birdNameZh, bird.birdNameLatin]
        .map((item: string) => this.normalizeMatchText(item))
        .filter((item: string) => item.length > 0)

      for (let j: number = 0; j < candidates.length; j++) {
        const candidate: string = candidates[j]
        if (values.some((value: string) => value === candidate || value.includes(candidate) || candidate.includes(value))) {
          return bird
        }
      }
    }

    return null
  }

  private findFallbackBird(recognitionLabel: string): RecognitionFallbackBird | null {
    const normalizedLabel: string = this.normalizeMatchText(recognitionLabel)
    for (let i: number = 0; i < this.FALLBACK_BIRDS.length; i++) {
      const item: RecognitionFallbackBird = this.FALLBACK_BIRDS[i]
      if (this.normalizeMatchText(item.recognitionLabel) === normalizedLabel) {
        return item
      }
    }
    return null
  }

  private resetRecognitionView() {
    this.resultDescription = ''
    this.currentBirdImage = null
    this.matchedBirdId = -1
  }

  private async applyRecognitionBird(topBird: BirdResult): Promise<void> {
    this.matchedBirdId = -1
    const confidenceText: string = `${(topBird.confidence * 100).toFixed(2)}%`

    try {
      const birds: BirdApiItem[] = await BirdBackendService.fetchBirds()
      const matchedBird: BirdApiItem | null = this.matchBirdFromDatabase(topBird.bird_name, birds)
      if (matchedBird !== null) {
        this.matchedBirdId = matchedBird.birdId
        this.currentBirdImage = mapPosterResource(matchedBird.birdPoster)
        this.resultDescription = this.buildBirdDescriptionFromApi(matchedBird)
        this.resultText = [
          '识别成功',
          `鸟类：${matchedBird.birdNameZh}`,
          `学名：${matchedBird.birdNameLatin}`,
          `置信度：${confidenceText}`
        ].join('\n')
        return
      }
    } catch (_e) {
    }

    const fallbackBird: RecognitionFallbackBird | null = this.findFallbackBird(topBird.bird_name)
    if (fallbackBird !== null) {
      this.currentBirdImage = mapPosterResource(fallbackBird.birdPoster)
      this.resultDescription = this.buildBirdDescriptionFromFallback(fallbackBird)
      this.resultText = [
        '识别成功',
        `鸟类：${fallbackBird.birdNameZh}`,
        `学名：${fallbackBird.birdNameLatin}`,
        `置信度：${confidenceText}`,
        '数据库中暂未收录该鸟类详情，当前为本地兜底说明。'
      ].join('\n')
      return
    }

    this.resultText = [
      '识别成功',
      `鸟类：${topBird.bird_name}`,
      `置信度：${confidenceText}`,
      '数据库中暂未匹配到对应图鉴。'
    ].join('\n')
  }

  private goBirdDetail() {
    if (this.matchedBirdId <= 0) {
      promptAction.showToast({ message: '数据库中暂无对应图鉴' })
      return
    }
    router.pushUrl({ url: 'pages/BirdDetail', params: { birdId: this.matchedBirdId } })
  }

  private async ensureLocationPermission(): Promise<boolean> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
    try {
      const bundleInfo: bundleManager.BundleInfo = bundleManager.getBundleInfoForSelfSync(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      )
      const tokenId: number = bundleInfo.appInfo?.accessTokenId as number

      const approximateStatus: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(
        tokenId,
        'ohos.permission.APPROXIMATELY_LOCATION'
      )
      const preciseStatus: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(
        tokenId,
        'ohos.permission.LOCATION'
      )

      if (approximateStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ||
        preciseStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true
      }

      await atManager.requestPermissionsFromUser(context, [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'
      ])

      const approximateStatusAfter: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(
        tokenId,
        'ohos.permission.APPROXIMATELY_LOCATION'
      )
      const preciseStatusAfter: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(
        tokenId,
        'ohos.permission.LOCATION'
      )

      return approximateStatusAfter === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ||
        preciseStatusAfter === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    } catch (_e) {
      return false
    }
  }

  private async getRecognitionLocation(): Promise<RecognitionLocation | null> {
    const hasLocationPermission: boolean = await this.ensureLocationPermission()
    if (!hasLocationPermission) {
      return null
    }

    try {
      const request: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 0
      }
      const location = await geoLocationManager.getCurrentLocation(request)
      if (!location || typeof location.latitude !== 'number' || typeof location.longitude !== 'number') {
        return null
      }

      return {
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: `${location.latitude.toFixed(4)}, ${location.longitude.toFixed(4)}`
      }
    } catch (_e) {
      return null
    }
  }

  private async saveRecognitionRecord(topBird: BirdResult): Promise<void> {
    if (this.matchedBirdId <= 0) {
      return
    }

    try {
      const location: RecognitionLocation | null = await this.getRecognitionLocation()
      await BirdBackendService.createRecognitionRecord({
        birdId: this.matchedBirdId,
        confidence: topBird.confidence,
        recognizedAt: Date.now(),
        latitude: location?.latitude,
        longitude: location?.longitude,
        locationName: location?.locationName,
        rawLabel: topBird.bird_name
      })
    } catch (e) {
      hilog.error(0x0000, 'BirdSoundRecognitionPage', `save record failed: ${JSON.stringify(e)}`)
    }
  }

  private async checkPermission(): Promise<boolean> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
    try {
      const bundleInfo: bundleManager.BundleInfo = bundleManager.getBundleInfoForSelfSync(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      )
      const tokenId: number = bundleInfo.appInfo?.accessTokenId as number
      const micPerm: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(tokenId, 'ohos.permission.MICROPHONE')

      if (micPerm === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        await atManager.requestPermissionsFromUser(context, ['ohos.permission.MICROPHONE', 'ohos.permission.INTERNET'])
      }
      return true
    } catch (_e) {
      return false
    }
  }

  private createFile(): string {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    const path: string = `${context.filesDir}/bird_audio`
    if (!fileIo.accessSync(path)) {
      fileIo.mkdirSync(path)
    }
    const filePath: string = `${path}/${Date.now()}.wav`
    const file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.CREATE)
    fileIo.closeSync(file)
    return filePath
  }

  private async handleClick() {
    if (this.isRecording) {
      this.isRecording = false
      this.recordBtnText = '开始录音'
      await AudioCapture.stop()

      setTimeout(() => {
        if (this.recordedFilePath !== '' && fileIo.accessSync(this.recordedFilePath)) {
          const stat: fileIo.Stat = fileIo.statSync(this.recordedFilePath)
          if (stat.size > 100) {
            this.resultText = '录音完成，点击下方按钮开始识别。'
          } else {
            this.resultText = '录音文件过小，请重试或改用上传音频。'
          }
        }
      }, 300)
      return
    }

    const hasPermission: boolean = await this.checkPermission()
    if (!hasPermission) {
      promptAction.showToast({ message: '请先授予录音权限' })
      return
    }

    this.recordedFilePath = this.createFile()
    this.isRecording = true
    this.recordBtnText = '停止录音'
    this.resultText = '正在录音中...'
    this.resetRecognitionView()

    AudioCapture.start(this.recordedFilePath).catch((err: Error) => {
      if (this.isRecording) {
        this.isRecording = false
        this.recordBtnText = '开始录音'
        this.resultText = '录音启动失败'
      }
      hilog.error(0x0000, 'BirdSoundRecognitionPage', `record start failed: ${err.message}`)
    })
  }

  private async uploadAudioData(buffer: ArrayBuffer, fileName: string = 'bird.wav') {
    this.isRecognizing = true
    this.resultText = '正在识别中...'
    this.resetRecognitionView()

    const boundary: string = `----Boundary${Date.now()}`
    const headerStr: string =
      `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${fileName}"\r\nContent-Type: audio/wav\r\n\r\n`
    const footerStr: string = `\r\n--${boundary}--\r\n`
    const headerBuf: ArrayBuffer = this.stringToArrayBuffer(headerStr)
    const footerBuf: ArrayBuffer = this.stringToArrayBuffer(footerStr)
    const fullBody: Uint8Array = new Uint8Array(headerBuf.byteLength + buffer.byteLength + footerBuf.byteLength)
    fullBody.set(new Uint8Array(headerBuf), 0)
    fullBody.set(new Uint8Array(buffer), headerBuf.byteLength)
    fullBody.set(new Uint8Array(footerBuf), headerBuf.byteLength + buffer.byteLength)

    const httpRequest: http.HttpRequest = http.createHttp()
    try {
      const response = await httpRequest.request(this.SERVER_URL, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': `multipart/form-data; boundary=${boundary}` },
        extraData: fullBody.buffer,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 60000,
        readTimeout: 60000
      })

      if (response.responseCode === 200 && response.result !== null) {
        const res: BackendResponse = JSON.parse(response.result as string) as BackendResponse
        if (res.code === 200 && res.data && res.data.length > 0) {
          const topBird: BirdResult = res.data[0]
          await this.applyRecognitionBird(topBird)
          await this.saveRecognitionRecord(topBird)
        } else {
          this.resultText = '未识别到有效鸟类。'
        }
      } else {
        this.resultText = '识别失败。'
      }
    } catch (e) {
      this.resultText = '网络连接失败。'
      hilog.error(0x0000, 'BirdSoundRecognitionPage', `upload failed: ${JSON.stringify(e)}`)
    } finally {
      httpRequest.destroy()
      this.isRecognizing = false
    }
  }

  private async uploadRecordedFile() {
    if (this.recordedFilePath === '' || !fileIo.accessSync(this.recordedFilePath)) {
      promptAction.showToast({ message: '请先录制一段音频' })
      return
    }

    const file: fileIo.File = fileIo.openSync(this.recordedFilePath, fileIo.OpenMode.READ_ONLY)
    const stat: fileIo.Stat = fileIo.statSync(file.fd)
    const buffer: ArrayBuffer = new ArrayBuffer(stat.size)
    fileIo.readSync(file.fd, buffer)
    fileIo.closeSync(file)

    await this.uploadAudioData(buffer, 'recorded.wav')
  }

  private async pickAndUploadAudio() {
    try {
      const documentPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker()
      const options: picker.DocumentSelectOptions = {
        maxSelectNumber: 1
      }
      const uris: Array<string> = await documentPicker.select(options)

      if (uris && uris.length > 0) {
        const selectedUri: string = uris[0]
        const file: fileIo.File = fileIo.openSync(selectedUri, fileIo.OpenMode.READ_ONLY)
        const stat: fileIo.Stat = fileIo.statSync(file.fd)
        const buffer: ArrayBuffer = new ArrayBuffer(stat.size)
        fileIo.readSync(file.fd, buffer)
        fileIo.closeSync(file)

        let fileName: string = 'uploaded.wav'
        const lastSlashIndex: number = selectedUri.lastIndexOf('/')
        if (lastSlashIndex !== -1) {
          fileName = selectedUri.substring(lastSlashIndex + 1)
        }

        await this.uploadAudioData(buffer, fileName)
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError
      if (err.code !== 20000001) {
        promptAction.showToast({ message: '选择文件失败' })
      }
    }
  }

  private navClick(index: number) {
    if (index === this.currentNavIndex) {
      return
    }
    const target: string = this.navItems[index].route
    router.replaceUrl({ url: target })
    this.currentNavIndex = index
  }

  @Builder
  BottomBar() {
    Row() {
      ForEach(this.navItems, (item: NavItem, idx: number) => {
        Column() {
          Image(item.icon)
            .width(24)
            .height(24)
            .fillColor(this.currentNavIndex === idx ? '#4CAF50' : '#999999')
          Text(item.name)
            .fontSize(10)
            .fontColor(this.currentNavIndex === idx ? '#4CAF50' : '#999999')
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

  build() {
    Stack() {
      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 12 }) {
            Text('听声识鸟')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ top: 40, bottom: 8 })

            Text(this.resultText)
              .fontSize(18)
              .lineHeight(28)
              .fontWeight(FontWeight.Medium)
              .padding(20)
              .width('90%')
              .borderRadius(12)
              .backgroundColor('#F5F5F5')
              .textAlign(TextAlign.Center)

            if (this.currentBirdImage !== null) {
              Image(this.currentBirdImage)
                .width('90%')
                .constraintSize({ maxHeight: 220 })
                .objectFit(ImageFit.Contain)
                .borderRadius(12)
                .margin({ top: 4 })
            }

            if (this.resultDescription !== '') {
              Text(this.resultDescription)
                .fontSize(15)
                .lineHeight(24)
                .padding({ left: 20, right: 20, top: 16, bottom: 16 })
                .width('90%')
                .borderRadius(12)
                .backgroundColor('#E8F5E9')
                .fontColor('#2E7D32')
                .textAlign(TextAlign.Start)
            }

            if (this.matchedBirdId > 0) {
              Button('查看对应图鉴')
                .margin({ top: 4 })
                .backgroundColor('#4CAF50')
                .fontColor('#FFFFFF')
                .onClick(() => this.goBirdDetail())
            }
          }

          if (this.isRecording || this.isRecognizing) {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#007DFF')
          }

          Column({ space: 15 }) {
            Button(this.recordBtnText) {
              Stack() {
                Circle()
                  .width(280)
                  .height(280)
                  .fill(this.isRecording ? '#FFEBEE' : '#E8F5E9')
                  .opacity(0.5)
                Circle()
                  .width(240)
                  .height(240)
                  .fill(this.isRecording ? '#EF9A9A' : '#C8E6C9')
                  .opacity(0.7)
                Circle()
                  .width(200)
                  .height(200)
                  .fill(this.isRecording ? '#F44336' : '#4CAF50')
                  .shadow({
                    radius: 20,
                    color: this.isRecording ? '#F44336' : '#4CAF50',
                    offsetX: 0,
                    offsetY: 8
                  })
                Column() {
                  Image(this.isRecording ? $r('app.media.ic_stop') : $r('app.media.ic_microphone'))
                    .width(48)
                    .height(48)
                    .fillColor('#FFFFFF')
                    .margin({ bottom: 8 })
                  Text(this.recordBtnText)
                    .fontSize(16)
                    .fontColor('#FFFFFF')
                }
              }
            }
            .width(280)
            .height(280)
            .type(ButtonType.Normal)
            .backgroundColor('#00000000')
            .enabled(!this.isRecognizing)
            .onClick(() => this.handleClick())

            Button('识别刚才的录音')
              .width('80%')
              .height(50)
              .backgroundColor('#007DFF')
              .enabled(!this.isRecording && !this.isRecognizing && this.recordedFilePath !== '')
              .onClick(() => this.uploadRecordedFile())

            Row() {
              Column({ space: 4 }) {
                Image($r('app.media.ic_history'))
                  .width(24)
                  .height(24)
                  .fillColor('#666666')
                Text('识别记录')
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .layoutWeight(1)
              .onClick(() => {
                router.pushUrl({ url: 'pages/RecognitionHistoryPage' })
              })

              Column({ space: 4 }) {
                Image($r('app.media.ic_public_folder'))
                  .width(24)
                  .height(24)
                  .fillColor('#666666')
                Text('上传音频')
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .layoutWeight(1)
              .enabled(!this.isRecognizing)
              .onClick(() => this.pickAndUploadAudio())
            }
            .width('100%')
            .margin({ top: 8 })
          }
          .padding({ top: 10, bottom: 20 })
        }
        .width('100%')
        .padding({ bottom: 80 })
      }
      .scrollBar(BarState.Auto)
      .enableScrollInteraction(true)
      .width('100%')
      .height('100%')

      Column() {
        Blank()
        this.BottomBar()
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}
