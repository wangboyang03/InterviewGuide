import { Permissions, Want } from '@kit.AbilityKit';
import { ATManager, AudioAmplitudeStyle,
  AudioDataBaseStorage,
  AudioItemComponent, AudioRecordComponent,
  Auth,
  Constants,
  InterviewAudioItem, Logger, NavigationBar,
  UserResponse } from 'basic';
import { promptAction } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import media from '@ohos.multimedia.media';
import { InputFileNameDialog } from '../views/InputFileNameDialog';
import { AudioPlayerSheet } from '../views/AudioPlayerBind';

@Entry
@Component
struct RecordingPage {
  @StorageProp(Constants.USER_STORAGE_KEY) user: UserResponse = {} as UserResponse
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
  @State list: InterviewAudioItem[] = []
  @State currentItem: InterviewAudioItem = {} as InterviewAudioItem
  inputDialog = new CustomDialogController({
    builder: InputFileNameDialog({
      name: this.currentItem.name,
      onSubmit: async (name) => {
        if (name) {
          this.currentItem.name = name
          await AudioDataBaseStorage.getInstance().update(this.currentItem)
          this.list = await AudioDataBaseStorage.getInstance().query(this.user.id)
          this.inputDialog.close()
        }
      }
    }),
    customStyle: true
  })
  @State isShowBind:boolean =  false

  async aboutToAppear(): Promise<void> {
    this.requestPermission()
    await AudioDataBaseStorage.getInstance().initStore() // 一进入页面就要初始化数据库
    this.list = await AudioDataBaseStorage.getInstance().query(this.user.id)
    console.log(JSON.stringify(this.list))
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
                item
              }).onClick(() => {
                this.isShowBind = true
                this.currentItem = item
              })
            }.swipeAction({
              end: this.ListItemSwiperBuilder(item)
            })
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      AudioRecordComponent({
        onRecorderData: async (item) => {
          // 在此插入数据
          await AudioDataBaseStorage.getInstance().insert(item)
          this.list = await AudioDataBaseStorage.getInstance().query(this.user.id)
        },
      })
    }
    .width('100%')
    .height('100%')
    .bindContentCover($$this.isShowBind, this.ShowAudioPlayerBind())
  }

  @Builder ListItemSwiperBuilder(item: InterviewAudioItem) {
    Row() {
      Text('编辑')
        .actionButton($r('app.color.common_blue'))
        .onClick(async () => {
          this.currentItem = item
          this.inputDialog.open()
        })
      Text('删除')
        .actionButton('#FF0033')
        .onClick(async () => {
          if (!!item.id) {
            await AudioDataBaseStorage.getInstance().delete(item.id)
            this.list = await AudioDataBaseStorage.getInstance().query(this.user.id)
          }
        })
    }
    .height('100%')
  }

  @Builder ShowAudioPlayerBind() {
    Column() {
      AudioPlayerSheet({
        currentItem: this.currentItem
      })
    }
  }
}

@Extend(Text) function actionButton(color: ResourceColor) {
  .width(80)
  .aspectRatio(1)
  .backgroundColor(color)
  .textAlign(TextAlign.Center)
  .fontColor($r('app.color.white'))
}