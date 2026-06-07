import { Auth, BasicTool, ClockSignIn, Constants, PAGE_PATH, StatusManager, UserResponse } from "basic"
import { NavigationResponse, Tool } from "../models"

@Component
export struct MineView {
  @StorageProp(Constants.SAFE_TOP_HEIGHT_KEY) topHeight: number = 0
  @StorageProp(Constants.USER_STORAGE_KEY) user: UserResponse = {} as UserResponse

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Image(this.user.avatar ?? $r('app.media.ic_mine_avatar'))
          .alt($r('app.media.ic_mine_avatar'))
          .width(55)
          .aspectRatio(1)
          .borderRadius(55)
        // 是否登录
        if (!!this.user.token) {
          Column({ space: 4 }) {
            Text(this.user.nickName ?? this.user.username)
              .fontSize(18)
              .fontWeight(500)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Row({ space: 4 }) {
              Text('编辑信息')
                .fontSize(12)
                .fontColor($r('app.color.common_gray_01'))
              Image($r('app.media.ic_mine_edit'))
                .width(12)
                .aspectRatio(1)
                .fillColor($r('app.color.common_gray_01'))
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        } else {
          Text('立即登录')
            .fontSize(18)
            .fontWeight(500)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: PAGE_PATH.LOGIN_PAGE
              })
            })
        }
        ClockSignIn({ clockInCount: this.user.clockinNumbers }).onClick(() => BasicTool.getInstance().getClockInNumber()) // 签到组件
      }
      .width('100%')
      .height(100)
      .margin({ top: this.topHeight })

      GridRow({ columns: 4 }) {
        this.navigationBuilder({
          icon: $r('app.media.ic_mine_history'), name: '历史记录', onClick: () => {
            // TODO
          }
        })
        this.navigationBuilder({
          icon: $r('app.media.ic_mine_collect'), name: '我的收藏', onClick: () => {
            // TODO
          }
        })
        this.navigationBuilder({
          icon: $r('app.media.ic_mine_like'), name: '我的点赞', onClick: () => {
            // TODO
          }
        })
        this.navigationBuilder({
          icon: $r('app.media.ic_mine_study'),
          name: '累计学时',
          other: BasicTool.getInstance().formatTimeFromSeconds(this.user.totalTime),
          onClick: (): void => Auth.getInstance().checkAuth({
            url: PAGE_PATH.STUDY_TIME_PAGE
          })
        })
      }
      .backgroundColor($r('app.color.white'))
      .padding(16)
      .borderRadius(8)

      Column() {
        this.toolsBuilder({
          icon: $r('app.media.ic_mine_notes'), name: '开发常用词', onClick: () => this.getUIContext().getRouter().pushUrl({url: PAGE_PATH.WORDS_PAGE})
        })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_ai'), name: '面通AI' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_invite'), name: '推荐分享' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_file'), name: '意见反馈', onClick: (): void => Auth.getInstance().checkAuth({
            url: PAGE_PATH.RECORDING_PAGE
          }) })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_info'), name: '关于我们' })
        this.toolsBuilder({
          icon: $r('app.media.ic_mine_setting'), name: '设置', onClick: () => {
            // TODO
          }
        })
      }
      .backgroundColor($r('app.color.white'))
      .borderRadius(8)

      Column({ space: 10 }) {
        Button('修改token模拟失效')
          .onClick(() => {
            this.user.token = 'x'
            Auth.getInstance().setUser(this.user)
          })
        Button('清空token')
          .onClick(() => {
            this.user.token = ''
            Auth.getInstance().setUser({} as UserResponse)
          })
        Button('模拟refreshToken失效').onClick(() => {
          this.user.refreshToken = 'x'
          Auth.getInstance().setUser(this.user)
        })
      }
    }
    .padding(16)
    .backgroundColor($r('app.color.common_gray_bg'))
    .linearGradient({
      colors: [['#FFB071', 0], [$r('app.color.common_gray_bg'), 0.3], [$r('app.color.common_gray_bg'), 1]]
    })
    .width('100%')
    .height('100%')
    .onVisibleAreaChange([0, 1], (visible) => {
      if (visible) {
        StatusManager.getInstance().setLightBar()
      } else {
        StatusManager.getInstance().setDarkBar()
      }
    })
  }

  @Builder
  navigationBuilder(navigation: NavigationResponse) {
    GridCol() {
      Column() {
        Image(navigation.icon)
          .width(30)
          .aspectRatio(1)
          .margin({ bottom: 10 })
        Text(navigation.name)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_03'))
          .margin({ bottom: 4 })
        if (navigation.other) {
          Row() {
            Text(navigation.other)
              .fontSize(12)
              .fontColor($r('app.color.common_gray_01'))
            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(12)
              .aspectRatio(1)
              .fillColor($r('app.color.common_gray_01'))
          }
        }
      }
      .onClick(() => navigation.onClick && navigation.onClick())
    }
  }

  @Builder toolsBuilder(tool: Tool) {
    Row() {
      Image(tool.icon)
        .width(16)
        .aspectRatio(1)
        .margin({ right: 12 })
      Text(tool.name)
        .fontSize(14)
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(12)
          .fontColor($r('app.color.common_gray_01'))
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .padding({ left: 16, right: 10 })
    .onClick(() => {
      tool.onClick && tool.onClick()
    })
  }
}