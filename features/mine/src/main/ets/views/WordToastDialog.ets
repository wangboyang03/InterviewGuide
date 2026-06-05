import { media } from "@kit.MediaKit"
import { Constants } from "basic"

@CustomDialog
export struct WordDialog {
  controller: CustomDialogController
  @Prop en: string = ''
  @Prop zh: string = ''
  avPlayer?: media.AVPlayer

  async aboutToAppear(): Promise<void> {
    try {
      const avPlayer = await media.createAVPlayer()
      avPlayer.url = `${Constants.PLAY_SOUND_WORD_URL}${this.en}`
      avPlayer.on('stateChange', (state) => {
        if (state == 'initialized') {
          // 初始化好了
          avPlayer.prepare()
        } else if (state == 'prepared') {
          // 准备好了
          avPlayer.loop = true
          avPlayer.play()
        }
        this.avPlayer = avPlayer
      })
    } catch (error) {
      // 日志
    }

  }

  aboutToDisappear(): void {
    this.avPlayer?.stop()
  }

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Text(this.en)
          .fontSize(20)
          .fontColor($r('app.color.white'))
          .fontWeight(500)
        WordToastDialog()
      }

      Text(this.zh)
        .fontColor($r('app.color.white'))
    }
    .constraintSize({ minWidth: 175 })
    .padding({ left: 16, right: 16 })
    .height(90)
    .borderRadius(45)
    .backgroundColor('#8f000000')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct WordToastDialog {
  @State flag: boolean = false
  timerId?: number

  aboutToAppear(): void {
    this.timerId = setInterval(() => {
      this.flag = !this.flag
    }, 500)
  }

  aboutToDisappear(): void {
    clearInterval(this.timerId)
  }

  build() {
    Image($r('sys.media.ohos_ic_public_sound'))
      .width(20)
      .aspectRatio(1)
      .fillColor(this.flag ? $r('app.color.common_green') : $r('app.color.white'))
  }
}