/**
 * 基于axios封装的http请求工具类
 */
import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { Auth, Logger, PAGE_PATH, UserResponse } from '../../../../Index'
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
}, (error: AxiosError) => {
  if (error.response?.status == 401) {
    Auth.getInstance().setUser({} as UserResponse) // 清空磁盘的用户信息
    // 跳转到登录页面
    router.pushUrl({ url: PAGE_PATH.LOGIN_PAGE }, router.RouterMode.Single)
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
