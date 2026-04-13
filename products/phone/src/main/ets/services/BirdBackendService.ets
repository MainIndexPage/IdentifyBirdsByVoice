import { http } from '@kit.NetworkKit'

interface ApiResponse<T> {
  code: number
  msg: string
  data: T
}

interface ApiResponseLike<T> {
  code?: number
  msg?: string
  data?: T
}

interface HttpHeaders {
  'Content-Type': string
  Authorization?: string
}

interface BirdApiPayload {
  birdId?: number
  bird_id?: number
  birdNameZh?: string
  bird_nameZh?: string
  bird_name_zh?: string
  birdNameLatin?: string
  bird_nameLatin?: string
  bird_name_latin?: string
  birdFamily?: string
  bird_family?: string
  birdHabitat?: string
  bird_habitat?: string
  birdProtection?: string
  bird_protection?: string
  birdPoster?: string
  bird_poster?: string
  birdCall?: string
  bird_call?: string
  birdDistribution?: string
  bird_distribution?: string
  birdLivingHabits?: string
  bird_living_habits?: string
  birdBreeding?: string
  bird_breeding?: string
  birdIntro?: string
  bird_intro?: string
}

interface PostApiPayload {
  id?: number
  userId?: string
  user_id?: string
  userName?: string
  user_name?: string
  userAvatar?: string
  user_avatar?: string
  birdName?: string
  bird_name?: string
  birdImage?: string
  bird_image?: string
  description?: string
  tags?: string
  location?: string
  privacy?: string
  images?: string
  video?: string
  likes?: number
  comments?: number
  shares?: number
  isLiked?: boolean
  is_liked?: number
  createdAt?: string
  created_at?: string
}

interface VolunteerProjectApiPayload {
  id?: number
  role?: string
  requirementText?: string
  requirement_text?: string
  location?: string
  serviceTime?: string
  service_time?: string
  serviceTimeType?: string
  service_time_type?: string
  totalSpots?: number
  total_spots?: number
  remainingSpots?: number
  remaining_spots?: number
  imageKey?: string
  image_key?: string
  description?: string
  contactName?: string
  contact_name?: string
  contactPhone?: string
  contact_phone?: string
  status?: string
  sortOrder?: number
  sort_order?: number
}

interface RecognitionHistoryApiPayload {
  id?: number
  birdId?: number
  bird_id?: number
  confidence?: number
  recognizedAt?: number
  recognized_at?: number
  latitude?: number
  longitude?: number
  locationName?: string
  location_name?: string
  rawLabel?: string
  raw_label?: string
  birdNameZh?: string
  bird_nameZh?: string
  bird_name_zh?: string
  birdNameLatin?: string
  bird_nameLatin?: string
  bird_name_latin?: string
  birdPoster?: string
  bird_poster?: string
}

export interface BirdApiItem {
  birdId: number
  birdNameZh: string
  birdNameLatin: string
  birdFamily: string
  birdHabitat: string
  birdProtection: string
  birdPoster: string
  birdCall: string
  birdDistribution: string
  birdLivingHabits: string
  birdBreeding: string
  birdIntro: string
}

export interface CommunityPostItem {
  id: string
  userId: string
  userName: string
  userAvatar: string
  birdName: string
  birdImage: string
  description: string
  tags: string[]
  location: string
  privacy: string
  images: string[]
  video: string
  likes: number
  comments: number
  shares: number
  isLiked: boolean
  timestamp: number
}

export interface CreateCommunityPostPayload {
  userId: string
  userName: string
  userAvatar: string
  birdName: string
  birdImage: string
  description: string
  tags: string[]
  location: string
  privacy: string
  images: string[]
  video: string
}

export interface VolunteerProjectItem {
  id: string
  role: string
  requirementText: string
  location: string
  serviceTime: string
  serviceTimeType: string
  totalSpots: number
  remainingSpots: number
  imageKey: string
  description: string
  contactName: string
  contactPhone: string
  status: string
  sortOrder: number
}

export interface RecognitionHistoryItem {
  id: string
  birdId: number
  confidence: number
  recognizedAt: number
  latitude?: number
  longitude?: number
  locationName: string
  rawLabel: string
  birdNameZh: string
  birdNameLatin: string
  birdPoster: string
}

export interface RegisterPayload {
  phone: string
  password: string
  nickname?: string
}

export interface LoginPayload {
  phone: string
  password: string
}

export interface LoginResult {
  token: string
  userId: string
  nickname: string
}

export interface GenerateBirdImagePayload {
  prompt: string
  negativePrompt?: string
  size?: string
  n?: number
  promptExtend?: boolean
  watermark?: boolean
}

export interface GenerateBirdImageResult {
  requestId: string
  model: string
  prompt: string
  imageUrl: string
  imageUrls: string[]
}

export type PosterSource = Resource | string

export interface CreateRecognitionRecordPayload {
  birdId: number
  confidence: number
  recognizedAt?: number
  latitude?: number
  longitude?: number
  locationName?: string
  rawLabel?: string
}

function normalizeText(value: string | null | undefined, fallback: string = ''): string {
  if (value === null || value === undefined) return fallback
  return value
}

function normalizeNumber(value: number | null | undefined, fallback: number = 0): number {
  if (value === null || value === undefined || Number.isNaN(value)) return fallback
  return value
}

function normalizeOptionalNumber(value: number | null | undefined): number | undefined {
  if (value === null || value === undefined || Number.isNaN(value)) return undefined
  return value
}

function pickText(
  primary: string | null | undefined,
  secondary: string | null | undefined,
  tertiary: string | null | undefined,
  fallback: string = ''
): string {
  if (primary !== null && primary !== undefined) return normalizeText(primary, fallback)
  if (secondary !== null && secondary !== undefined) return normalizeText(secondary, fallback)
  if (tertiary !== null && tertiary !== undefined) return normalizeText(tertiary, fallback)
  return fallback
}

function pickNumber(
  primary: number | null | undefined,
  secondary: number | null | undefined,
  fallback: number = 0
): number {
  if (primary !== null && primary !== undefined && !Number.isNaN(primary)) return primary
  if (secondary !== null && secondary !== undefined && !Number.isNaN(secondary)) return secondary
  return fallback
}

function parseCsvTags(value: string | null | undefined): string[] {
  if (value === null || value === undefined || value.trim().length === 0) return []
  return value.split(',').map((tag: string) => tag.trim()).filter((tag: string) => tag.length > 0)
}

function parseJsonImages(value: string | null | undefined): string[] {
  if (value === null || value === undefined || value.trim().length === 0) return []
  try {
    const parsed = JSON.parse(value) as string[]
    if (Array.isArray(parsed)) return parsed
    return []
  } catch (_e) {
    return []
  }
}

export function mapPosterResource(_posterKey: string | null | undefined): PosterSource {
  const normalizedInput: string = normalizeText(_posterKey, '').trim()
  if (normalizedInput.length === 0) {
    return $r('app.media.ic_close')
  }

  if (normalizedInput.startsWith('http://') || normalizedInput.startsWith('https://')) {
    return normalizedInput
  }

  if (normalizedInput.startsWith('/')) {
    return `${BirdBackendService.getBaseUrl()}${normalizedInput}`
  }

  if (normalizedInput.includes('/')) {
    return `${BirdBackendService.getBaseUrl()}/${normalizedInput.replace(/^\/+/, '')}`
  }

  const normalizedKey: string = normalizedInput.startsWith('app.media.')
    ? normalizedInput.substring(10)
    : normalizedInput

  switch (normalizedKey) {
    case 'Urocissa_erythroryncha': return $r('app.media.Urocissa_erythroryncha')
    case 'Platalea_minor': return $r('app.media.Platalea_minor')
    case 'Alcedo_atthis': return $r('app.media.Alcedo_atthis')
    case 'Nipponia_nippon': return $r('app.media.Nipponia_nippon')
    case 'Mergus_squamatus': return $r('app.media.Mergus_squamatus')
    case 'Tragopan_caboti': return $r('app.media.Tragopan_caboti')
    case 'Grus_nigricollis': return $r('app.media.Grus_nigricollis')
    case 'Crossoptilon_mantchuricum': return $r('app.media.Crossoptilon_mantchuricum')
    case 'Chrysolophus_amherstiae': return $r('app.media.Chrysolophus_amherstiae')
    case 'Chrysolophus_pictus': return $r('app.media.Chrysolophus_pictus')
    case 'Ciconia_boyciana': return $r('app.media.Ciconia_boyciana')
    case 'Cygnus_cygnus': return $r('app.media.Cygnus_cygnus')
    case 'Aix_galericulata': return $r('app.media.Aix_galericulata')
    case 'Pseudocolopteryx_acutipennis_Subtropical_Doradito': return $r('app.media.Pseudocolopteryx_acutipennis_Subtropical_Doradito')
    case 'Mellisuga_helenae_Bee_Hummingbird': return $r('app.media.Mellisuga_helenae_Bee_Hummingbird')
    default: {
      const posterFileName: string = /\.(png|jpg|jpeg|webp)$/i.test(normalizedKey)
        ? normalizedKey
        : `${normalizedKey}.png`
      return `${BirdBackendService.getBaseUrl()}/media/birds/${encodeURIComponent(posterFileName)}`
    }
  }
}
export function mapCallResource(_callKey: string | null | undefined): Resource {
  return $r('app.media.voice')
}

export function mapVolunteerProjectResource(imageKey: string | null | undefined): Resource {
  const normalizedInput: string = normalizeText(imageKey, '')
  const normalizedKey: string = normalizedInput.startsWith('app.media.')
    ? normalizedInput.substring(10)
    : normalizedInput

  switch (normalizedKey) {
    case 'news_dongtan': return $r('app.media.news_dongtan')
    case 'news_owl': return $r('app.media.news_owl')
    case 'news_discovery': return $r('app.media.news_discovery')
    case 'img_donate_banner': return $r('app.media.img_donate_banner')
    default: return $r('app.media.ic_close')
  }
}

export class BirdBackendService {
  private static readonly BASE_URLS: string[] = [
    'http://10.0.2.2:8001',
    'http://127.0.0.1:8001',
    'http://localhost:8001'
  ]
  private static activeBaseUrl: string = BirdBackendService.BASE_URLS[0]

  private static readonly API_PREFIX: string = '/api/catalog'
  private static readonly COMMUNITY_PREFIX: string = '/api/community/posts'
  private static readonly AUTH_PREFIX: string = '/api/auth'
  private static readonly VOLUNTEER_PREFIX: string = '/api/volunteer'
  private static readonly AI_PREFIX: string = '/api/ai/image'

  private static authToken: string = ''
  private static loginUserId: string = ''

  static getBaseUrl(): string {
    return BirdBackendService.activeBaseUrl.length > 0
      ? BirdBackendService.activeBaseUrl
      : BirdBackendService.BASE_URLS[0]
  }

  private static readToken(): string {
    const raw: Object | undefined = AppStorage.get('authToken') as Object | undefined
    if (typeof raw === 'string') {
      return raw
    }
    return ''
  }

  private static readUserId(): string {
    const raw: Object | undefined = AppStorage.get('loginUserId') as Object | undefined
    if (typeof raw === 'string') {
      return raw
    }
    return ''
  }

  static setAuthToken(token: string) {
    AppStorage.setOrCreate('authToken', token)
    BirdBackendService.authToken = token
  }

  static getAuthToken(): string {
    const t: string = BirdBackendService.readToken()
    BirdBackendService.authToken = t
    return t
  }

  static clearAuthToken() {
    AppStorage.setOrCreate('authToken', '')
    AppStorage.setOrCreate('loginUserId', '')
    BirdBackendService.authToken = ''
    BirdBackendService.loginUserId = ''
  }

  static getLoginUserId(): string {
    const uid: string = BirdBackendService.readUserId()
    BirdBackendService.loginUserId = uid
    return uid
  }

  private static async requestApiWithPrefix<T>(
    apiPrefix: string,
    path: string,
    method: http.RequestMethod,
    body?: Object
  ): Promise<ApiResponse<T>> {
    let lastError: string = 'unknown error'

    for (let i = 0; i < BirdBackendService.BASE_URLS.length; i++) {
      const baseUrl: string = BirdBackendService.BASE_URLS[i]
      const req: http.HttpRequest = http.createHttp()

      try {
        const url: string = `${baseUrl}${apiPrefix}${path}`

        const headers: HttpHeaders = {
          'Content-Type': 'application/json'
        }
        const token: string = BirdBackendService.getAuthToken()
        if (token.length > 0) {
          headers.Authorization = `Bearer ${token}`
        }

        const options: http.HttpRequestOptions = {
          method: method,
          header: headers,
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 15000,
          readTimeout: 15000
        }

        if (body !== null && body !== undefined) {
          options.extraData = JSON.stringify(body)
        }

        const resp = await req.request(url, options)

        if (resp.responseCode !== 200 || resp.result === null) {
          lastError = `base=${baseUrl}, code=${resp.responseCode}`
          continue
        }

        const parsed = JSON.parse(resp.result as string) as ApiResponseLike<T> | T
        const wrapped = parsed as ApiResponseLike<T>
        BirdBackendService.activeBaseUrl = baseUrl
        if (wrapped.code !== undefined) {
          return {
            code: wrapped.code,
            msg: normalizeText(wrapped.msg, 'ok'),
            data: wrapped.data as T
          }
        }

        return {
          code: 200,
          msg: 'ok',
          data: parsed as T
        }
      } catch (e) {
        lastError = `base=${baseUrl}, err=${JSON.stringify(e)}`
      } finally {
        req.destroy()
      }
    }

    throw new Error(`All backend endpoints failed: ${lastError}`)
  }

  private static async requestApi<T>(
    path: string,
    method: http.RequestMethod,
    body?: Object
  ): Promise<ApiResponse<T>> {
    return BirdBackendService.requestApiWithPrefix<T>(BirdBackendService.API_PREFIX, path, method, body)
  }

  private static async requestCommunityApi<T>(
    path: string,
    method: http.RequestMethod,
    body?: Object
  ): Promise<ApiResponse<T>> {
    return BirdBackendService.requestApiWithPrefix<T>(BirdBackendService.COMMUNITY_PREFIX, path, method, body)
  }

  private static async requestAuthApi<T>(
    path: string,
    method: http.RequestMethod,
    body?: Object
  ): Promise<ApiResponse<T>> {
    return BirdBackendService.requestApiWithPrefix<T>(BirdBackendService.AUTH_PREFIX, path, method, body)
  }

  private static async requestVolunteerApi<T>(path: string, method: http.RequestMethod): Promise<ApiResponse<T>> {
    return BirdBackendService.requestApiWithPrefix<T>(BirdBackendService.VOLUNTEER_PREFIX, path, method)
  }

  private static async requestAiApi<T>(
    path: string,
    method: http.RequestMethod,
    body?: Object
  ): Promise<ApiResponse<T>> {
    return BirdBackendService.requestApiWithPrefix<T>(BirdBackendService.AI_PREFIX, path, method, body)
  }

  static async register(payload: RegisterPayload): Promise<boolean> {
    const res = await BirdBackendService.requestAuthApi<boolean>('/register', http.RequestMethod.POST, payload as Object)
    return res.code === 200
  }

  static async login(payload: LoginPayload): Promise<LoginResult | null> {
    const res = await BirdBackendService.requestAuthApi<LoginResult>('/login', http.RequestMethod.POST, payload as Object)
    if (res.code !== 200 || !res.data) return null

    BirdBackendService.authToken = res.data.token
    BirdBackendService.loginUserId = res.data.userId
    AppStorage.setOrCreate('authToken', res.data.token)
    AppStorage.setOrCreate('loginUserId', res.data.userId)
    return res.data
  }

  private static normalizeBird(item: BirdApiPayload): BirdApiItem {
    return {
      birdId: normalizeNumber(pickNumber(item.birdId, item.bird_id, 0), 0),
      birdNameZh: pickText(item.birdNameZh, item.bird_nameZh, item.bird_name_zh, '未知鸟类'),
      birdNameLatin: pickText(item.birdNameLatin, item.bird_nameLatin, item.bird_name_latin, ''),
      birdFamily: pickText(item.birdFamily, item.bird_family, undefined, ''),
      birdHabitat: pickText(item.birdHabitat, item.bird_habitat, undefined, ''),
      birdProtection: pickText(item.birdProtection, item.bird_protection, undefined, ''),
      birdPoster: pickText(item.birdPoster, item.bird_poster, undefined, ''),
      birdCall: pickText(item.birdCall, item.bird_call, undefined, ''),
      birdDistribution: pickText(item.birdDistribution, item.bird_distribution, undefined, ''),
      birdLivingHabits: pickText(item.birdLivingHabits, item.bird_living_habits, undefined, ''),
      birdBreeding: pickText(item.birdBreeding, item.bird_breeding, undefined, ''),
      birdIntro: pickText(item.birdIntro, item.bird_intro, undefined, '')
    }
  }

  static async fetchBirds(): Promise<BirdApiItem[]> {
    const res = await BirdBackendService.requestApi<BirdApiPayload[]>('/birds', http.RequestMethod.GET)
    if (res.code !== 200 || !res.data || !Array.isArray(res.data)) return []
    return res.data.map((item: BirdApiPayload) => BirdBackendService.normalizeBird(item))
  }

  static async fetchBirdById(birdId: number): Promise<BirdApiItem | null> {
    const res = await BirdBackendService.requestApi<BirdApiPayload>(`/birds/${birdId}`, http.RequestMethod.GET)
    if (res.code !== 200 || !res.data) return null
    return BirdBackendService.normalizeBird(res.data)
  }

  static async createRecognitionRecord(payload: CreateRecognitionRecordPayload): Promise<boolean> {
    const requestBody: CreateRecognitionRecordPayload = {
      birdId: payload.birdId,
      confidence: payload.confidence,
      recognizedAt: payload.recognizedAt || Date.now(),
      latitude: payload.latitude,
      longitude: payload.longitude,
      locationName: payload.locationName,
      rawLabel: payload.rawLabel
    }

    const res = await BirdBackendService.requestApi<string>('/recognitions', http.RequestMethod.POST, requestBody as Object)
    return res.code === 200
  }

  static async fetchRecognitionHistory(limit: number = 50): Promise<RecognitionHistoryItem[]> {
    const safeLimit: number = Math.max(1, Math.min(limit, 200))
    const res = await BirdBackendService.requestApi<RecognitionHistoryApiPayload[]>(
      `/recognitions/history?limit=${safeLimit}`,
      http.RequestMethod.GET
    )
    if (res.code !== 200 || !res.data || !Array.isArray(res.data)) return []
    return res.data.map((item: RecognitionHistoryApiPayload) => BirdBackendService.normalizeRecognitionHistory(item))
  }

  private static normalizeCommunityPost(item: PostApiPayload): CommunityPostItem {
    const createdText: string = normalizeText(pickText(item.createdAt, item.created_at, undefined, ''), '')
    const createdTimestamp: number = createdText.length > 0 ? Date.parse(createdText) : Date.now()
    const likedValue: boolean = item.isLiked !== undefined ? !!item.isLiked : normalizeNumber(item.is_liked, 0) === 1

    return {
      id: normalizeNumber(item.id, 0).toString(),
      userId: pickText(item.userId, item.user_id, undefined, ''),
      userName: pickText(item.userName, item.user_name, undefined, 'Unknown'),
      userAvatar: pickText(item.userAvatar, item.user_avatar, undefined, ''),
      birdName: pickText(item.birdName, item.bird_name, undefined, 'Unknown Bird'),
      birdImage: pickText(item.birdImage, item.bird_image, undefined, ''),
      description: normalizeText(item.description, ''),
      tags: parseCsvTags(item.tags),
      location: normalizeText(item.location, ''),
      privacy: normalizeText(item.privacy, 'PUBLIC'),
      images: parseJsonImages(item.images),
      video: normalizeText(item.video, ''),
      likes: normalizeNumber(item.likes, 0),
      comments: normalizeNumber(item.comments, 0),
      shares: normalizeNumber(item.shares, 0),
      isLiked: likedValue,
      timestamp: Number.isNaN(createdTimestamp) ? Date.now() : createdTimestamp
    }
  }

  private static normalizeVolunteerProject(item: VolunteerProjectApiPayload): VolunteerProjectItem {
    return {
      id: normalizeNumber(item.id, 0).toString(),
      role: normalizeText(item.role, ''),
      requirementText: pickText(item.requirementText, item.requirement_text, undefined, ''),
      location: normalizeText(item.location, ''),
      serviceTime: pickText(item.serviceTime, item.service_time, undefined, ''),
      serviceTimeType: pickText(item.serviceTimeType, item.service_time_type, undefined, '全部时间'),
      totalSpots: normalizeNumber(pickNumber(item.totalSpots, item.total_spots, 0), 0),
      remainingSpots: normalizeNumber(pickNumber(item.remainingSpots, item.remaining_spots, 0), 0),
      imageKey: pickText(item.imageKey, item.image_key, undefined, ''),
      description: normalizeText(item.description, ''),
      contactName: pickText(item.contactName, item.contact_name, undefined, ''),
      contactPhone: pickText(item.contactPhone, item.contact_phone, undefined, ''),
      status: normalizeText(item.status, 'OPEN'),
      sortOrder: normalizeNumber(pickNumber(item.sortOrder, item.sort_order, 0), 0)
    }
  }

  private static normalizeRecognitionHistory(item: RecognitionHistoryApiPayload): RecognitionHistoryItem {
    return {
      id: normalizeNumber(item.id, 0).toString(),
      birdId: normalizeNumber(pickNumber(item.birdId, item.bird_id, 0), 0),
      confidence: normalizeNumber(item.confidence, 0),
      recognizedAt: normalizeNumber(pickNumber(item.recognizedAt, item.recognized_at, 0), 0),
      latitude: normalizeOptionalNumber(item.latitude),
      longitude: normalizeOptionalNumber(item.longitude),
      locationName: pickText(item.locationName, item.location_name, undefined, ''),
      rawLabel: pickText(item.rawLabel, item.raw_label, undefined, ''),
      birdNameZh: pickText(item.birdNameZh, item.bird_nameZh, item.bird_name_zh, '未知鸟类'),
      birdNameLatin: pickText(item.birdNameLatin, item.bird_nameLatin, item.bird_name_latin, ''),
      birdPoster: pickText(item.birdPoster, item.bird_poster, undefined, '')
    }
  }

  static async fetchCommunityPosts(): Promise<CommunityPostItem[]> {
    const res = await BirdBackendService.requestCommunityApi<PostApiPayload[]>('', http.RequestMethod.GET)
    if (res.code !== 200 || !res.data || !Array.isArray(res.data)) return []
    return res.data.map((item: PostApiPayload) => BirdBackendService.normalizeCommunityPost(item))
  }

  static async createCommunityPost(payload: CreateCommunityPostPayload): Promise<CommunityPostItem | null> {
    const res = await BirdBackendService.requestCommunityApi<PostApiPayload>('', http.RequestMethod.POST, payload as Object)
    if (res.code !== 200 || !res.data) return null
    return BirdBackendService.normalizeCommunityPost(res.data)
  }

  static async likeCommunityPost(postId: string, liked: boolean): Promise<CommunityPostItem | null> {
    const res = await BirdBackendService.requestCommunityApi<PostApiPayload>(
      `/${postId}/like?liked=${liked ? 'true' : 'false'}`,
      http.RequestMethod.POST
    )
    if (res.code !== 200 || !res.data) return null
    return BirdBackendService.normalizeCommunityPost(res.data)
  }

  static async deleteCommunityPost(postId: string): Promise<boolean> {
    const res = await BirdBackendService.requestCommunityApi<boolean>(`/${postId}`, http.RequestMethod.DELETE)
    return res.code === 200
  }

  static async fetchVolunteerProjects(): Promise<VolunteerProjectItem[]> {
    const res = await BirdBackendService.requestVolunteerApi<VolunteerProjectApiPayload[]>('/projects', http.RequestMethod.GET)
    if (res.code !== 200 || !res.data || !Array.isArray(res.data)) return []
    return res.data.map((item: VolunteerProjectApiPayload) => BirdBackendService.normalizeVolunteerProject(item))
  }

  static async generateBirdImage(payload: GenerateBirdImagePayload): Promise<GenerateBirdImageResult> {
    const requestBody: GenerateBirdImagePayload = {
      prompt: payload.prompt,
      negativePrompt: payload.negativePrompt,
      size: payload.size || '1024*1024',
      n: payload.n || 1,
      promptExtend: payload.promptExtend !== undefined ? payload.promptExtend : true,
      watermark: payload.watermark !== undefined ? payload.watermark : false
    }

    const res = await BirdBackendService.requestAiApi<GenerateBirdImageResult>(
      '/generate',
      http.RequestMethod.POST,
      requestBody as Object
    )

    if (res.code !== 200 || !res.data || !res.data.imageUrl || res.data.imageUrl.length === 0) {
      throw new Error(normalizeText(res.msg, '图片生成失败'))
    }

    return res.data
  }
}



