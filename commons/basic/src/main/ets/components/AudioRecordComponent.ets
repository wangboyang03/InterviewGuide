import { media } from "@kit.MediaKit"
import { Constants } from "../Constants"
import { AudioAmplitudeStyle } from "./AudioAmplitudeStyle"
import { fileIo } from "@kit.CoreFileKit"
import { Logger } from "../utils/Logger"
import { InterviewAudioItem } from "../utils"
import { UserResponse } from "../models"

@Component
export struct AudioRecordComponent {
  @StorageProp(Constants.SAFE_BOTTOM_HEIGHT_KEY) bottomHeight: number = 0
  @StorageProp(Constants.USER_STORAGE_KEY) user: UserResponse = {} as UserResponse
  avRecorder?: media.AVRecorder
  fd?: number
  filePath?: string
  timer?: number
  @State maxAmplitude: number = 0
  @State isRecording: boolean = false
  onRecorderData: (item: InterviewAudioItem) => void = () => {}
  @State startRecordTime: number = 0

  /**
   * 开始录制音频和停止录制
   */
  async startRecord() {
    // 1.准备文件路径
    const context = this.getUIContext().getHostContext()
    const filePath = context?.filesDir + '/' + Date.now() + '.mp3'
    // 2.以创建或读写模式打开文件
    const file = fileIo.openSync(filePath, (fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE))
    this.fd = file.fd
    this.filePath = file.path
    // 3.创建录音配置对象
    const config: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: {
        audioBitrate: 100000,
        audioChannels: 1,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        audioSampleRate: 48000,
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
      },
      url: `fd://${this.fd}` // 文件句柄
    }
    // 4.创建录音实例
    const recordObject = await media.createAVRecorder()
    await recordObject.prepare(config)
    this.avRecorder = recordObject
    // 5.开始录音
    this.avRecorder.start()
    this.startRecordTime = Date.now()
    // 6.获取输入声音的最大振幅 使用心跳检测 最大30000
    this.timer = setInterval(async () => {
      this.maxAmplitude = await recordObject.getAudioCapturerMaxAmplitude()
      Logger.info('maxAmplitude', this.maxAmplitude.toString())
    }, 100)
  }

  async stopRecord() {
    if (this.avRecorder) {
      this.avRecorder?.stop()
      this.avRecorder.release()
      fileIo.closeSync(this.fd)
      clearInterval(this.timer)
    }
  }

  build() {
    Column() {
      AudioAmplitudeStyle({ maxAmplitude: this.maxAmplitude })
      Row() {
        Image($r('sys.media.ohos_ic_public_voice'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('app.color.white'))
          .onClick(async () => {
            if (!this.isRecording) {
              await this.startRecord()
              this.isRecording = true
            } else {
              await this.stopRecord()
              this.isRecording = false
              // 获取文件信息
              const file = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_ONLY)
              const fileStat = fileIo.statSync(file.fd)
              // 生成一条数据给父组件
              this.onRecorderData({
                id: null,
                user_id: this.user.id,
                name: this.filePath ?? "",
                path: this.filePath ?? "",
                duration: Date.now() - this.startRecordTime,
                size: fileStat.size,
                create_time: Date.now()
              })
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .height(50)
      .width(50)
      .borderRadius(25)
      .margin({ top: 20 })
      .backgroundColor(this.isRecording ? $r('app.color.common_main_color') : $r('app.color.common_gray_bg'))
    }
    .width('100%')
    .height(240)
    .backgroundColor($r('app.color.common_gray_bg'))
    .padding({
      bottom: this.bottomHeight,
      left: 80,
      right: 80,
      top: 20
    })
  }
}