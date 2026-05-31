import axios, { AxiosError, AxiosRequestConfig, AxiosResponse } from '@ohos/axios'
import { hmLogger } from '.'

export const baseURL = 'https://api-harmony-teach.itheima.net/hm/'

// 1. 创建axios实例对象
const instance = axios.create({
  baseURL, // 配置基础地址(baseUrl)
  timeout: 100000 // 配置超时时间
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