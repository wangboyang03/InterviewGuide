import { Auth, Constants, Logger, LoginRequest, NavigationBar, NetworkUtil, UserResponse } from 'basic'
import emitter from '@ohos.events.emitter'
import { WebViewResponse } from '../models'

@Entry
@Component
struct LoginPage {
  @State username: string = 'hmheima'
  @State password: string = 'Hmheima%123'
  @State isAgree: boolean = false
  @State loggingIn: boolean = false

  async Login() {
    if (this.loggingIn) {
      return;
    }
    if (!this.username.trim() || !this.password.trim()) {
      this.getUIContext().getPromptAction().showToast({ message: '用户名或密码不能为空' })
      return;
    }
    if (!this.isAgree) {
      this.getUIContext().getPromptAction().showToast({ message: '请勾选已阅读协议并同意' })
      return;
    }
    // 前端校验完毕 可以登陆了
    try {
      this.loggingIn = true
      const user = await NetworkUtil.getInstance().request<UserResponse, LoginRequest>({
        url: Constants.LOGIN,
        method: 'post',
        data: {
          username: this.username,
          password: this.password
        }
      })
      // AppStorage.setOrCreate<UserResponse>(Constants.USER_STORAGE_KEY, user) // 存储用户信息
      Auth.getInstance().setUser(user) // 持久化用户信息
      emitter.emit(Constants.LOGIN_EVENT) // 登录成功发送首页数据刷新事件
      // 判断是否需要跳转拦截
      const router = this.getUIContext().getRouter()
      const params = router.getParams() as Record<string, string> ?? {}
      if (params?.return_url) {
        router.replaceUrl({
          url: params.return_url,
          params
        })
      } else {
        router.back()
      }
    } catch (error) {
      Logger.log(error)
    } finally {
      this.loggingIn = false
    }
  }

  build() {
    Column() {
      NavigationBar({ showRightIcon: false, onLeftClick: () => this.getUIContext().getRouter().back() })
      Column() {
        Image($r('app.media.icon'))
          .width(120)
          .aspectRatio(1)
        Text('面试通')
          .fontSize(28)
          .margin({ bottom: 15 })
        Text('搞定企业面试真题，就用面试通')
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
      }
      .padding(16)

      Column({ space: 15 }) {
        TextInput({ placeholder: '请输入用户名', text: $$this.username })
          .customStyle()
        TextInput({ placeholder: '请输入密码', text: $$this.password })
          .type(InputType.Password)
          .showPasswordIcon(false)
          .customStyle()
        Row() {
          Checkbox()
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .selectedColor('#fa711d')
            .size({ width: 14, height: 14 })
            .select(this.isAgree)
            .onChange((val) => {
              this.isAgree = val
            })
          Text('已阅读并同意')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_01'))
            .padding({ right: 4 })
          Text('用户协议')
            .fontSize(14)
            .padding({ right: 4 })
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/WebPage',
                params: {
                  title: '用户协议',
                  src: 'http://110.41.143.89/user'
                } as WebViewResponse
              })
            })
          Text('和')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_01'))
            .padding({ right: 4 })
          Text('隐私政策')
            .fontSize(14)
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/WebPage',
                params: {
                  title: '隐私政策',
                  src: 'http://110.41.143.89/privacy'
                } as WebViewResponse
              })
            })
        }
        .width('100%')

        Button({ type: ButtonType.Normal }) {
          Row() {
            if (this.loggingIn) {
              LoadingProgress()
                .color($r('app.color.white'))
                .width(24)
                .height(24)
                .margin({ right: 10 })
            }
            Text('立即登录').fontColor($r('app.color.white'))
          }
        }
        .width('100%')
        .backgroundColor('none')
        .borderRadius(4)
        .height(44)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#fc9c1c', 0], ['#fa711d', 1]]
        })
        .stateEffect(false)
        .onClick(() => this.Login())
      }
      .padding({ left: 36, right: 36, top: 30 })
      Column() {
        Text('其他登录方式')
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
        // 放华为登录
      }
      .padding({ top: 70, bottom: 100 })
    }
    .width('100%')
    .height('100%')
  }
}

@Extend(TextInput)
function customStyle() {
  .placeholderColor('#C3C3C5')
  .caretColor('#fa711d')
  .height(44)
  .borderRadius(0)
  .backgroundColor($r('app.color.white'))
  .border({ width: { bottom: 0.5 }, color: $r('app.color.common_gray_border') })
}