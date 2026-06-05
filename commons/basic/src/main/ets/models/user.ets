export interface LoginRequest {
  username: string
  password: string
}

export interface UserResponse {
  avatar?: string;
  clockinNumbers: number; // 打卡次数
  id: string;
  nickName: string;
  refreshToken: string;
  shareInfo?: string;
  token: string;
  totalTime: number;
  username?: string;
}

export interface ClockInResponse {
  /**
   * 头像
   */
  avatar: string;
  /**
   * 背景图片地址
   */
  backgroudPicture: string;
  /**
   * 连续打卡的天数
   */
  clockinNumbers: number;
  /**
   * 打卡总天数
   */
  clockinTotal: number;
  /**
   * 小程序二维码
   */
  miniAppPicture: string;
  /**
   * 昵称
   */
  nickName: string;
}

export interface ClockInItem {
  id: string,
  createdAt: string
}

export interface ClockInPageResponse {
  flag?: boolean
  clockinNumbers: number
  totalClockinNumber: number
  clockins: ClockInItem[]
}

export interface ClockInPageRequest {
  year: string,
  month: string
}