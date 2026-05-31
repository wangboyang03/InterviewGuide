import { HMNavigationBar } from '../commons/components/HMNavigationBar'
import { GlobalVariable } from '../commons/constants'
import { hmHttp } from '../commons/utils/HMHttp'
import { LoginParams, User } from '../models'

@Entry
@Component
struct LoginPage {
  @StorageProp('topHeight')
  topHeight: number = 0
  @State
  username: string = 'hmheima'
  @State
  password: string = 'Hmheima%123'
  @State
  isAgree: boolean = false
  @State
  loading: boolean = false

  /**
   * 登录校验
   */
  async login() {
    if (this.loading) {
      return;
    }
    if (!this.username.trim() || !this.password.trim()) {
      this.getUIContext().getPromptAction().showToast({ message: '用户名或密码不能为空'})
    }
    if (!this.isAgree) {
      this.getUIContext().getPromptAction().showToast({ message: '请先同意协议'})
    }
    // 可以请求登录接口
    try {
      this.loading = true
      const result = await hmHttp.request<User,LoginParams>({
        url:'login',
        method: 'post',
        data:{
          username: this.username,
          password: this.password
        } as LoginParams
      })
      AppStorage.setOrCreate<User>(GlobalVariable.USER_KEY,result) // 存储用户信息到全局
      this.getUIContext().getRouter().back() // 返回
    } catch (error) {
      // 日志.
      this.getUIContext().getPromptAction().showToast({message: '请检查用户名和密码是否匹配'})
    } finally {
      this.loading = false
    }

  }

  build() {
    Column() {
      HMNavigationBar({ showRightIcon: false })
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
          Text('和')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_01'))
            .padding({ right: 4 })
          Text('隐私政策')
            .fontSize(14)
        }
        .width('100%')

        Button({ type: ButtonType.Normal }) {
          Row() {
            if (this.loading) {
              LoadingProgress()
                .color($r('app.color.white'))
                .width(24)
                .height(24)
                .margin({ right: 10 })
            }
            Text('立即登录')
              .fontColor($r('app.color.white'))
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
        .stateEffect(false) // 设置是否开启按压态显示效果
        .onClick(() => {
          this.login()
        })
      }
      .padding({ left: 36, right: 36, top: 30 })


      Column() {
        Text('其他登录方式')
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
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