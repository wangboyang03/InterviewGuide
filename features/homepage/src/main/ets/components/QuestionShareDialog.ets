import { Constants, UserResponse, Logger } from "basic"
import { QuestionDetail, } from "../models"
import { image } from "@kit.ImageKit"
import fileIo from "@ohos.file.fs"
import { fileUri } from "@kit.CoreFileKit"
import { photoAccessHelper } from "@kit.MediaLibraryKit"

@CustomDialog
export struct QuestionShareDialog {
  @Prop item: QuestionDetail
  @StorageProp(Constants.USER_STORAGE_KEY) user: UserResponse = {} as UserResponse
  controller: CustomDialogController

  /**
   * 将组件进行截图 先保存截图到沙箱 再保存到系统相册
   * @access 需要申请权限：ohos.permission.WRITE_IMAGEVIDEO
   */
  async saveImageFromShareComponent() {
    try {
      // 1.通过组件id进行组件截图
      const pixelMap = await this.getUIContext().getComponentSnapshot().get('share')
      // 2.获取图片生成器
      const imagePacker = image.createImagePacker()
      // 3.将像素转换为二进制数据流
      const arrayBuffer = await imagePacker.packToData(pixelMap, {format: 'image/jpeg', quality: 100})
      // 4.创建文件并将数据流写入文件
      const context = this.getUIContext().getHostContext()
      const filePath = context?.cacheDir + '/' + this.item.id + '.jpeg'
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE) // 打开文件
      fileIo.writeSync(file.fd, arrayBuffer) // 写入文件
      fileIo.closeSync(file.fd) // 关闭文件
      // 5.资产变更
      const uri = fileUri.getUriFromPath(filePath) // 拿到带有协议的文件路径
      const photoAccess = photoAccessHelper.getPhotoAccessHelper(context) // 获取相册访问工具
      const changeRequest = photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(context, uri) // 创建资产变更请求
      await photoAccess.applyChanges(changeRequest) // 应用资产变更
      this.controller.close()
      this.getUIContext().getPromptAction().showToast({message: '成功保存到相册'})
    } catch (error) {
      Logger.error('保存图片失败', error)
      this.getUIContext().getPromptAction().showToast({message: '保存图片失败'})
    }

  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 20 }) {
        Image($r('app.media.ic_interview_logo'))
          .width(40)
          .height(40)
        Text('面试通，搞定企业面试题')
        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.common_gray_border'))
        Text('大厂面试题：' + this.item.stem)
          .fontSize(12)
          .maxLines(2)
          .fontWeight(600)
          .width('100%')
          .lineHeight(24)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        QRCode(this.item.id)
          .width(160)
          .height(160)
          .alignSelf(ItemAlign.Center)
        Text('扫码查看答案')
          .fontSize(12)
          .alignSelf(ItemAlign.Center)
        Blank()
        Text('分享来自：' + this.user.nickName ?? this.user.username)
          .fontSize(12)
      }
      .id('share')  // 用于后续截图使用
      .padding(20)
      .alignItems(HorizontalAlign.Start)
      .width(300)
      .height(500)
      .backgroundColor($r('app.color.white'))


      Row() {
        Text('保存到本地')
          .fontColor($r('app.color.white'))
          .fontSize(14)
          .padding(12)
          .backgroundColor($r('app.color.common_main_color'))
      }
      .borderRadius({ topLeft: 8 })
      .clip(true)
      .onClick(() => this.saveImageFromShareComponent())
    }
    .borderRadius(8)
    .clip(true)
  }
}