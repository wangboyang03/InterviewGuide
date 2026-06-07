import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { ATManager } from 'basic';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct RecordingPage {
  // @State message: string = 'Hello World';
  permissions: Permissions[] = ['ohos.permission.MICROPHONE']
  confirmPopupParams: promptAction.ShowDialogOptions = {
    title: '提示',
    message: '未授权使用麦克风将无法使用面试录音功能,是否前往设置进行重新授权？',
    buttons: [
      { text: '离开', color: $r('app.color.common_gray_01') },
      { text: '去授权', color: $r('app.color.black') }
    ]
  }

  aboutToAppear(): void {
    this.requestPermission()
  }

  /**
   * 用户权限申请
   */
  async requestPermission() {
    try {
      const flag = await ATManager.getInstance().getAccessFromUser(this.permissions)
      if (!!flag) {
        this.getUIContext().getPromptAction().showToast({message: 'Permission granted'})
      } else {
        const confirm = await this.getUIContext().getPromptAction().showDialog(this.confirmPopupParams)
        if (confirm.index == 1) {
          // 用户同意去授权
          const flag = await ATManager.getInstance().getAccessFromSetting(this.permissions)
          if (!!flag) {
            this.getUIContext().getPromptAction().showToast({message: 'Permission granted'})
            return
          }
        }
        this.getUIContext().getRouter().back()
      }
    } catch (error) {
      this.getUIContext().getRouter().back()
    }
  }

  build() {
    
  }
}