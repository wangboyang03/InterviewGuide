import { Permissions, Want } from '@kit.AbilityKit';
import { ATManager, NavigationBar } from 'basic';
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
  fileFd?: number
  recordObject?: media.AVRecorder

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
    this.fileFd = file.fd
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
      url: `fd://${this.fileFd}` // 文件句柄
    }
    // 4.创建录音实例
    const recordObject = await media.createAVRecorder()
    await recordObject.prepare(config)
    this.recordObject = recordObject
    // 5.开始录音
    this.recordObject.start()
  }

  async stopRecord() {
    if (this.recordObject) {
      this.recordObject?.stop()
      this.recordObject.release()
      fileIo.closeSync(this.fileFd)
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
      Button("开始录音").onClick((event: ClickEvent) => this.startRecord())
      Button("停止录音").onClick((event: ClickEvent) => this.stopRecord())
    }
    .width('100%')
    .height('100%')
  }
}