import { Constants, PAGE_PATH } from "../Constants";
import { UserResponse } from "../models";
import { router } from "@kit.ArkUI";

export class Auth {
  private static sInstance: Auth;
  private constructor() {}

  public static getInstance(): Auth {
    if (!Auth.sInstance) {
      Auth.sInstance = new Auth();
    }
    return Auth.sInstance;
  }

  initUser() {
    PersistentStorage.persistProp<UserResponse>(Constants.USER_STORAGE_KEY, {} as UserResponse)
  }

  setUser(user: UserResponse) {
    AppStorage.setOrCreate(Constants.USER_STORAGE_KEY, user)
  }

  getUser() {
    return AppStorage.get<UserResponse>(Constants.USER_STORAGE_KEY)
  }

  /**
   * 跳转鉴权
   */
  checkAuth(options: router.RouterOptions | Function) {
    const user = this.getUser()
    if (user?.token) {
      if (typeof options == 'function') {
        options()
      } else {
        router.pushUrl(options) // 直接放行跳转
      }
    } else {
      if (typeof options == 'function') {
        router.pushUrl({
          url: PAGE_PATH.LOGIN_PAGE
        })
      } else {
        // 解析路由参数
        const params = options.params as Record<string, string> ?? {}
        params.return_url = options.url
        router.pushUrl({
          url: PAGE_PATH.LOGIN_PAGE,
          params
        })
      }
    }
  }
}