import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { HMAuth, hmLogger } from '.'
import { User } from '../../models'
import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'

export const baseURL = 'https://api-harmony-teach.itheima.net/hm/'

// 1. 创建axios实例对象
const instance = axios.create({
  baseURL, // 配置基础地址(baseUrl)
  timeout: 100000 // 配置超时时间
})

// 4.请求拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const user = HMAuth.getInstance().getUser()
  if (user.token) {
    config.headers.Authorization = `Bearer ${user.token}`
  }
  // 在发送前修改请求配置
  return config
},
  (error: AxiosError) => {
    return Promise.reject(error)
  })

// 2. 配置响应拦截器
instance.interceptors.response.use((res: AxiosResponse) => {
  // 2.1 请求成功，业务成功
  if (res.data.code === 10000) {
    return res.data.data
  }
  // 2.2 请求成功，业务失败
  return Promise.reject(res.data)
}, (err: AxiosError) => {
  hmLogger.error(err)
  if (err.response?.status == 401) {
    HMAuth.getInstance().setUser({} as User) // 清空持久化的用户信息
    router.pushUrl({url:'page/LoginPage'}, router.RouterMode.Single)
    promptAction.showToast({ message: '登录状态失效,请重新登录'})
  }
  return Promise.reject(err)
})

// 3. 封装Http类
class HMHttp {
  // 提供request方法
  request<ResponseData, RequestData = object>(config: AxiosRequestConfig<RequestData>) {
    return instance<null, ResponseData, RequestData>(config)
  }
}

// 4. 创建并导出http实例对象
export const hmHttp = new HMHttp()

// hmHttp.request({ url: '', method: 'post', params: {}, data: {} })