import { Auth, Constants, NavigationBar, NetworkUtil, UserResponse } from 'basic'
import { CustomLoadingDialog } from 'homepage'
import { fileIo, picker } from '@kit.CoreFileKit'
import { FormData } from '@ohos/axios'
import { image } from '@kit.ImageKit'
import { ImageUtil } from '@pura/harmony-utils'

@Entry
@Component
struct ProfilePage {
  @StorageProp(Constants.USER_STORAGE_KEY) user: UserResponse = {} as UserResponse
  dialog: CustomDialogController = new CustomDialogController({
    builder: CustomLoadingDialog({ label: '更新中...' }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  async updateNickName() {
    try {
      await NetworkUtil.getInstance().request<null>({
        url: Constants.UPDATE_PROFILE,
        method: 'post',
        data: {
          nickName: this.user.nickName
        }
      })
      Auth.getInstance().setUser(this.user)
      this.getUIContext().getPromptAction().showToast({message: '变更用户信息成功'})
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({message: '变更用户信息失败'})
    }
  }

  async updateAvatar() {
    try {
      // 1.从相册选择一张图片并返回uri地址
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      const photoPicker = new picker.PhotoViewPicker()
      const photoSelectResult = await photoPicker.select(photoSelectOptions)
      if (photoSelectResult.photoUris.length > 0) {
        const photoUri = photoSelectResult.photoUris[0]
        // this.getUIContext().getPromptAction().showDialog({message:photoUri})
        // 2.根据uri地址复制文件到沙箱
        const context = this.getUIContext().getHostContext()
        if (context) {
          // const tempPath = context.cacheDir + '/' + Date.now() + '.jpg'
          // const file = fileIo.openSync(photoUri, fileIo.OpenMode.READ_ONLY) // 打开相册里的文件
          // const newFile = fileIo.openSync(tempPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
          // fileIo.copyFileSync(file.fd, newFile.fd)
          /** 这里发现相册里图片太大 网络请求比较慢 使用工具压缩一下吧
           * 方法1 使用图片生成器进行质量调整
           * 方法2 harmony-utils/ImageUtil 支持图片压缩 但是返回的路径并非沙箱临时目录 而是temp
           * **/
          // const imagePacker = image.createImagePacker()
          // const imageSource = image.createImageSource(tempPath) // 这里直接用相册路径不行 必须是沙箱路径
          // const fileZip = await imagePacker.packToData(imageSource, {
          //   /** 坑点: 如果返回ImageSource或PixelMap,是不支持jpg格式的 **/
          //   format: "image/jpeg",
          //   quality: 30
          // })
          // const zipPath = context.cacheDir + '/' + Date.now() + '_zip.jpeg'
          // const zipFile = fileIo.openSync(zipPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
          // fileIo.writeSync(zipFile.fd, fileZip)
          // fileIo.closeSync(zipFile.fd)
          const fileZipPath = await ImageUtil.compressPhoto(photoUri, 100)
          // fileIo.closeSync(file.fd)
          // fileIo.closeSync(newFile.fd)
          // this.getUIContext().getPromptAction().showDialog({message: newFile.path})
          // 3. 创建一个fromData对象 把键值传入 返回对象发送网络请求
          const formData = new FormData()
          // const fileName = tempPath.split('/').pop()
          const fileName = fileZipPath.split('/').pop()
          // formData.append('file', `internal://cache/${fileName}`)
          const currentYear = new Date().getFullYear()
          const currentMonth = String(new Date().getMonth() + 1).padStart(2, '0')
          const currentDay = String(new Date().getDate()).padStart(2, '0')
          const currentKeyPath = `${currentYear}-${currentMonth}-${currentDay}`
          formData.append('file', `internal://temp/${currentKeyPath}/${fileName}`)
          await NetworkUtil.getInstance().request<null>({
            url: Constants.UPDATE_AVATAR,
            method: 'post',
            headers: {
              'Content-Type': 'multipart/form-data'
            },
            data: formData, context
          })
          // 4.网络请求成功后 更新本地头像
          const result = await NetworkUtil.getInstance().request<UserResponse>({
            url: Constants.USER_INFO
          })
          this.user.avatar = result.avatar
          Auth.getInstance().setUser(this.user)
        }
      }
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({message: `更新头像失败,${error}`})
    }
  }

  build() {
    Column() {
      NavigationBar({ title: '编辑资料', showRightIcon: false })
      List() {
        ListItem() {
          Row() {
            Text('头像')
            Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
              .alt($r('app.media.ic_mine_avatar'))
              .width(40)
              .aspectRatio(1)
              .borderRadius(20)
              .border({ width: 0.5, color: $r('app.color.common_gray_border') })
              .onClick(() => this.updateAvatar())
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.SpaceBetween)
        }

        ListItem() {
          Row() {
            Text('昵称')
            TextInput({ text: this.user.nickName })
              .fontColor($r('app.color.common_gray_03'))
              .textAlign(TextAlign.End)
              .layoutWeight(1)
              .padding(0)
              .height(60)
              .backgroundColor($r('app.color.white'))
              .borderRadius(0)
              .onChange((value) => this.user.nickName = value)
              .onSubmit(() => this.updateNickName())
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 35,
        right: 35,
        top: 15,
        bottom: 15
      })
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_bg') })
    }
  }
}