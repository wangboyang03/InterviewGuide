import { Permissions, Want } from '@kit.AbilityKit';
import { ATManager, AudioAmplitudeStyle, Logger, NavigationBar } from 'basic';
import { promptAction } from '@kit.ArkUI';
import common from '@ohos.app.ability.common';
import { fileIo } from '@kit.CoreFileKit';
import media from '@ohos.multimedia.media';

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
  // 录音相关变量
  file?: fileIo.File
  recordObject?: media.AVRecorder
  timer?: number
  @State maxAmplitude: number = 0 // 每次保存的最大振幅必须是状态变量 否则无法触发视图刷新
  // 播音相关变量
  avPlayer?: media.AVPlayer
  @State audioTotal: number = 0
  @State currentProgram: number = 0

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

  /**
   * 开始录制音频和停止录制
   */
  async startRecord() {
    // 1.准备文件路径
    const context = this.getUIContext().getHostContext()
    const filePath = context?.filesDir + '/' + Date.now() + '.mp3'
    // 2.以创建或读写模式打开文件
    const file = fileIo.openSync(filePath, (fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE))
    this.file = file
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
      url: `fd://${this.file.fd}` // 文件句柄
    }
    // 4.创建录音实例
    const recordObject = await media.createAVRecorder()
    await recordObject.prepare(config)
    this.recordObject = recordObject
    // 5.开始录音
    this.recordObject.start()
    // 6.获取输入声音的最大振幅 使用心跳检测 最大30000
    this.timer = setInterval(async () => {
      this.maxAmplitude = await recordObject.getAudioCapturerMaxAmplitude()
      Logger.info('maxAmplitude', this.maxAmplitude.toString())
    }, 100)
  }

  async stopRecord() {
    if (this.recordObject) {
      this.recordObject?.stop()
      this.recordObject.release()
      fileIo.closeSync(this.file?.fd)
      clearInterval(this.timer)
    }
  }

  /**
   * 实现音频的播放和停止
   */
  async startPlayAudio() {
    try {
      if (!this.file) {
        this.getUIContext().getPromptAction().showToast({message:'请先开始录音'})
        return
      }
      if (!this.avPlayer) {
        const file = fileIo.openSync(this.file.path, fileIo.OpenMode.READ_ONLY)
        const avPlayer = await media.createAVPlayer()
        avPlayer.url = `fd://${this.file.fd}` // 设置播放源
        avPlayer.on('stateChange', (state)=>{
          if (state == 'initialized') {
            avPlayer.prepare()
          } else if (state == 'prepared') {
            avPlayer.loop = true //
            avPlayer.play()
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

  stopPlayAudio() {
    if (!!this.avPlayer) {
      this.avPlayer.stop()
      this.avPlayer.release()
    }
  }

  build() {
    Column() {
      NavigationBar({
        title: '面试录音',
        showRightIcon: false
      })
      Button("点击跳转设置页面").onClick((_: ClickEvent) => {
        const wantParams: Want = {
          bundleName: 'com.huawei.hmos.settings',
          abilityName: 'com.huawei.hmos.settings.MainAbility',
          uri: 'application_info_entry',
          parameters: {
            pushParams: 'com.taobao.interview_success_ai'
          }
        }
        const UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
        UIAbilityContext.startAbility(wantParams)
      })
      Row() {AudioAmplitudeStyle({maxAmplitude: this.maxAmplitude})}.width('80%')
      Button("开始录音").onClick((event: ClickEvent) => this.startRecord())
      Button("停止录音").onClick((event: ClickEvent) => this.stopRecord())

      Progress({ total: this.audioTotal, value: this.currentProgram }).width('100%').padding(10)
      Button("开始播放").onClick((event: ClickEvent) => this.startPlayAudio())
      Button("停止播放").onClick((event: ClickEvent) => this.stopPlayAudio())
    }
    .width('100%')
    .height('100%')
  }
}