import { Permissions, Want } from '@kit.AbilityKit';
import { ATManager, AudioAmplitudeStyle, AudioItemComponent,
  AudioRecordComponent,
  InterviewAudioItem, Logger, NavigationBar } from 'basic';
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
  @State list: InterviewAudioItem[] = [{} as InterviewAudioItem, {} as InterviewAudioItem]

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
      Column() {
        List() {
          ForEach(this.list, (item: InterviewAudioItem) => {
            ListItem() {
              AudioItemComponent({
                item: {
                  id: 1,
                  name: '2024年10月01日_10点10分10秒',
                  path: '/data/el/xxx',
                  user_id: '100',
                  duration: 10000,
                  size: 10000,
                  create_time: 10000
                }
              })
            }
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      AudioRecordComponent()
    }
    .width('100%')
    .height('100%')
  }
}