import { Auth, Constants, NavigationBar, NetworkUtil, UserResponse } from 'basic'
import { CustomLoadingDialog } from 'homepage'


@Entry
@Component
struct ProfilePage {
  @StorageProp(Constants.USER_STORAGE_KEY) user: UserResponse = {} as UserResponse
  dialog: CustomDialogController = new CustomDialogController({
    builder: CustomLoadingDialog({ label: '更新中...' }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  async updateNickName() {
    try {
      await NetworkUtil.getInstance().request<null>({
        url: Constants.UPDATE_PROFILE,
        method: 'post',
        data: {
          nickName: this.user.nickName
        }
      })
      Auth.getInstance().setUser(this.user)
      this.getUIContext().getPromptAction().showToast({message: '变更用户信息成功'})
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({message: '变更用户信息失败'})
    }
  }

  build() {
    Column() {
      NavigationBar({ title: '编辑资料', showRightIcon: false })
      List() {
        ListItem() {
          Row() {
            Text('头像')
            Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
              .alt($r('app.media.ic_mine_avatar'))
              .width(40)
              .aspectRatio(1)
              .borderRadius(20)
              .border({ width: 0.5, color: $r('app.color.common_gray_border') })
              .onClick(() => {
                // TODO 更新头像
              })
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.SpaceBetween)
        }

        ListItem() {
          Row() {
            Text('昵称')
            TextInput({ text: this.user.nickName })
              .fontColor($r('app.color.common_gray_03'))
              .textAlign(TextAlign.End)
              .layoutWeight(1)
              .padding(0)
              .height(60)
              .backgroundColor($r('app.color.white'))
              .borderRadius(0)
              .onChange((value) => this.user.nickName = value)
              .onSubmit(() => this.updateNickName())
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 35,
        right: 35,
        top: 15,
        bottom: 15
      })
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_bg') })
    }
  }
}