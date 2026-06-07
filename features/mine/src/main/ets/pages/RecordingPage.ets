import { abilityAccessCtrl } from '@kit.AbilityKit';
import { ATManager } from 'basic';

@Entry
@Component
struct RecordingPage {
  @State message: string = 'Hello World';

  async aboutToAppear(): Promise<void> {
    const flag = await ATManager.getInstance().getAccessFromUser(['ohos.permission.MICROPHONE'])
    if (!!flag) {
      this.getUIContext().getPromptAction().showToast({message:'Permission granted'})
    } else {
      const flag = await ATManager.getInstance().getAccessFromSetting(['ohos.permission.MICROPHONE'])
      if (!!flag) {
        this.getUIContext().getPromptAction().showToast({message:'Permission granted'})
      } else {
        this.getUIContext().getPromptAction().showToast({message:'Permission denied'})
        this.getUIContext().getRouter().back()
      }
    }
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message = 'Welcome';
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}