import { media } from "@kit.MediaKit"
import { fileIo } from "@kit.CoreFileKit"
import { InterviewAudioItem, Logger } from "basic"

@Component
export struct AudioPlayerSheet {
  // 播音相关变量
  avPlayer?: media.AVPlayer
  fd?: number
  @Prop currentItem: InterviewAudioItem = {} as InterviewAudioItem
  @State audioTotal: number = 0
  @State currentProgram: number = 0
  @State isPlaying: boolean = false

  /**
   * 实现音频的播放和停止
   */
  async startPlayAudio() {
    try {
      if (!this.avPlayer) {
        const file = fileIo.openSync(this.currentItem.path, fileIo.OpenMode.READ_ONLY)
        this.fd = file.fd
        const avPlayer = await media.createAVPlayer()
        avPlayer.url = `fd://${this.fd}` // 设置播放源
        avPlayer.on('stateChange', (state)=>{
          if (state == 'initialized') {
            avPlayer.prepare()
          } else if (state == 'prepared') {
            avPlayer.loop = true // 开启循环播放
            avPlayer.play()
            this.isPlaying = true
            this.audioTotal = avPlayer.duration
          }
        })
        this.avPlayer = avPlayer
        avPlayer.on('timeUpdate', (timeChange) => {
          this.currentProgram = timeChange // 监听时长变化
        })
      }
    } catch (error) {
      // 音频播放失败
      Logger.error('startPlayAudio', error)
    }
  }

  // 暂停播放
  async pausePlayAudio() {
    if (!!this.avPlayer) {
      await this.avPlayer.pause()
      this.isPlaying = false
    }
  }

  stopPlayAudio() {
    if (!!this.avPlayer) {
      this.avPlayer.stop()
      this.avPlayer.release()
    }
  }

  build() {
    Column({space: 10}) {
      Image($r('app.media.ic_mine_audio'))
        .width(100)
        .aspectRatio(1)
      Text(`当前正在播放的文件是${this.currentItem.name}`)
        .fontSize(18)

      Row({ space: 20 }) {
        Image(!this.isPlaying ? $r('sys.media.ohos_ic_public_play') : $r('sys.media.ohos_ic_public_pause'))
          .width(24)
          .aspectRatio(1)
          .onClick(() => {
            if (!this.isPlaying) {
              this.startPlayAudio()
            } else {
              this.pausePlayAudio()
            }
          })
        Progress({ value: this.currentProgram, total: this.audioTotal })
          .layoutWeight(1)
          .margin({ top: 20, bottom: 20 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_blue'))
    .justifyContent(FlexAlign.Center)
    .onDisAppear(() => this.stopPlayAudio())
  }
}