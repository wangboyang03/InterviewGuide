export class Constants {
  static readonly SAFE_TOP_HEIGHT_KEY = 'safe_top_height'
  static readonly SAFE_BOTTOM_HEIGHT_KEY = 'safe_bottom_height'
  static readonly LIGHT_COLOR: string = "#ffffff" // 白色
  static readonly DARK_COLOR: string = "#000000" // 暗色
  static readonly USER_STORAGE_KEY: string = "user_cip" // 用户信息存储key
  static readonly LOGIN_EVENT: string = "loginEvent" // 登录成功发生请求的事件名

  // 模块相关
  static readonly BUNDLE_NAME: string = "com.taobao.interview_success_ai" // 包名
  static readonly MINE_MODULE: string = "mine" // 我的模块
  static readonly HOMEPAGE_MODULE: string = "homepage" // 首页模块

  // 网络相关
  static readonly BASE_URL = 'https://api-harmony-teach.itheima.net/hm/' // 基地址
  static readonly NETWORK_TIME_OUT = 10000 // 请求超时时间
  static readonly SUCCESS_CODE = 10000 // 请求成功码
  static readonly QUESTION_TYPE = 'question/type' // 试题类型接口
  static readonly QUESTION_LIST = 'question/list' // 试题列表接口
  static readonly LOGIN = 'login' // 登录接口
  static readonly REFRESH_TOKEN = 'refreshToken' // 刷新token接口
  static readonly QUESTION_DETAIL = 'question/' // 试题详情接口
  static readonly OPTION_MENU = 'question/opt' // 操作试题点赞或收藏
  static readonly UN_OPTION_MENU = 'question/unOpt' // 操作试题取消点赞或收藏
}

export class PAGE_PATH {
  static readonly LOGIN_PAGE = `@bundle:${Constants.BUNDLE_NAME}/${Constants.MINE_MODULE}/ets/pages/LoginPage`
  static readonly QUESTION_PAGE = `@bundle:${Constants.BUNDLE_NAME}/${Constants.HOMEPAGE_MODULE}/ets/pages/QuestionPage`
  static readonly WEB_VIEW_PAGE = `@bundle:${Constants.BUNDLE_NAME}/${Constants.MINE_MODULE}/ets/pages/WebPage`
}