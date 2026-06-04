/**
 * 首页底Tab
 */
export interface TabItem {
  icon: ResourceStr;
  activeIcon: ResourceStr;
  name: string;
  title: string
}

/**
 * 公共响应返回
 */
export interface ResponseData<T = object> {
  code: number;
  message: string;
  data: T;
}

export interface TrackingRequest {
  endTime: number;
  questionId: string;
  startTime: number;
}