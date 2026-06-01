export class Constants {
  static readonly SAFE_TOP_HEIGHT_KEY = 'safe_top_height'
  static readonly SAFE_BOTTOM_HEIGHT_KEY = 'safe_bottom_height'
  static readonly LIGHT_COLOR: string = "#ffffff" // 白色
  static readonly DARK_COLOR: string = "#000000" // 暗色
  static readonly BUNDLE_NAME: string = "com.taobao.interview_success_ai" // 包名
  static readonly MINE_MODULE: string = "mine" // 我的模块

  // 网络相关
  static readonly BASE_URL = 'https://api-harmony-teach.itheima.net/hm/' // 基地址
  static readonly NETWORK_TIME_OUT = 10000 // 请求超时时间
  static readonly QUESTION_TYPE = 'question/type' // 试题类型接口
  static readonly QUESTION_LIST = 'question/list' // 试题列表接口
  static readonly LOGIN = 'login' // 登录接口
}

export class PAGE_PATH {
  static readonly LOGIN_PAGE = `@bundle:${Constants.BUNDLE_NAME}/${Constants.MINE_MODULE}/ets/pages/LoginPage`
}