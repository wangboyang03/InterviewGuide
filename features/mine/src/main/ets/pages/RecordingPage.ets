import { abilityAccessCtrl } from '@kit.AbilityKit';

@Entry
@Component
struct RecordingPage {
  @State message: string = 'Hello World';

  async aboutToAppear(): Promise<void> {
    try {
      const atManager = abilityAccessCtrl.createAtManager()
      const context = this.getUIContext().getHostContext()
      if (!!context) {
        const result = await atManager.requestPermissionsFromUser(context, ['ohos.permission.MICROPHONE'])
        const flag = result.authResults.every(item => item == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
        if (flag) {
          this.getUIContext().getPromptAction().showToast({message: '授权成功'})
        }
      }
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({message: `授权失败,${error}`})
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