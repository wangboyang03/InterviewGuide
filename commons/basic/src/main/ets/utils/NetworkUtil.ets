/**
 * 基于axios封装的http请求工具类
 */
import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { Auth, Logger, PAGE_PATH, ResponseData, UserResponse } from '../../../../Index'
import { Constants } from '../Constants'
import { router } from '@kit.ArkUI'

// 1.创建axios实例对象
const instance = axios.create({
  baseURL: Constants.BASE_URL,
  timeout: Constants.NETWORK_TIME_OUT
})

// 3.请求拦截器
instance.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    // 获取用户信息 并携带token
    const user = Auth.getInstance().getUser()
    if (user?.token) {
      config.headers.Authorization = `Bearer ${user.token}`
    }
    return config
  },
  (error: AxiosError) => {
    return Promise.reject(error)
  }
)

// 2.响应拦截器
instance.interceptors.response.use((res: AxiosResponse) => {
  // 请求成功 业务成功
  if (res.data.code == Constants.NETWORK_TIME_OUT) {
    return res.data.data
  }
  // 请求成功 业务失败
  return Promise.reject(res.data)
}, async (error: AxiosError) => {
  if (error.response?.status == 401) {
    // Auth.getInstance().setUser({} as UserResponse) // 清空磁盘的用户信息
    // 换取token 1.先看看refreshToken 2.需要用新的axios发请求 3.把新的双token赋值并存储 4.将之前错误的请求重新发出去
    const user = Auth.getInstance().getUser()
    if (!!user?.refreshToken) {
      try {
        const result = await axios.post<null, AxiosResponse<ResponseData, null>>(Constants.BASE_URL + Constants.REFRESH_TOKEN, null, {
            headers: {
              Authorization: `Bearer ${user?.refreshToken}`
            }
          })
        if (result.data?.code == 200) {
          user.token = result.data?.data['token']
          user.refreshToken = result.data?.data['refreshToken']
          Auth.getInstance().setUser(user) // 存储新的用户数据
          return instance(error.config) // 将错误请求重发出去
        }
      } catch (error) {
        // 刷新不了token
        Auth.getInstance().setUser({} as UserResponse) // 清空磁盘的用户信息
        router.pushUrl({ url: PAGE_PATH.LOGIN_PAGE }, router.RouterMode.Single) // 前往登录页重新登录
      }
    } else {
      Auth.getInstance().setUser({} as UserResponse)
      router.pushUrl({ url: PAGE_PATH.LOGIN_PAGE }, router.RouterMode.Single)
    }
  }
  Logger.error(error)
  return Promise.reject(error)
})

export class NetworkUtil {
  private static sInstance: NetworkUtil
  private constructor() {}

  public static getInstance(): NetworkUtil {
    if (NetworkUtil.sInstance == null) {
      NetworkUtil.sInstance = new NetworkUtil()
    }
    return NetworkUtil.sInstance
  }

  /**
   * 请求方法
   * @param AxiosRequestConfig
   * @returns Promise<ResponseData>
   * @example NetworkUtil.getInstance().request({ url: '', method: 'post', params: {}, data: {} })
   */
  request<ResponseData, RequestData = object>(config: AxiosRequestConfig<RequestData>) {
    return instance<null, ResponseData, RequestData>(config)
  }
}
