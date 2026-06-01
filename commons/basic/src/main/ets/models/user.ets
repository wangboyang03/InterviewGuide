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