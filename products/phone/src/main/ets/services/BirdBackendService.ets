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

function normalizeText(value: string | null | undefined, fallback: string = ''): string {
  if (value === null || value === undefined) return fallback
  return value
}

function normalizeNumber(value: number | null | undefined, fallback: number = 0): number {
  if (value === null || value === undefined || Number.isNaN(value)) return fallback
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

export function mapPosterResource(_posterKey: string | null | undefined): Resource {
  const normalizedInput: string = normalizeText(_posterKey, '')
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
    default: return $r('app.media.ic_close')
  }
}

export function mapCallResource(_callKey: string | null | undefined): Resource {
  return $r('app.media.voice')
}

export class BirdBackendService {
  private static readonly BASE_URLS: string[] = [
    'http://10.0.2.2:8000',
    'http://127.0.0.1:8000',
    'http://localhost:8000'
  ]

  private static readonly API_PREFIX: string = '/api/catalog'
  private static readonly COMMUNITY_PREFIX: string = '/api/community/posts'
  private static readonly AUTH_PREFIX: string = '/api/auth'

  private static authToken: string = ''
  private static loginUserId: string = ''

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

  private static async requestApi<T>(path: string, method: http.RequestMethod): Promise<ApiResponse<T>> {
    return BirdBackendService.requestApiWithPrefix<T>(BirdBackendService.API_PREFIX, path, method)
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
}