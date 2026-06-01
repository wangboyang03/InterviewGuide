import { Constants } from "../Constants";

@Component
export struct NavigationBar {
  @StorageProp(Constants.SAFE_TOP_HEIGHT_KEY) topHeight: number = 0
  @Prop title: string = '' // 标题文字
  @Prop showBorder: boolean = false // 是否有下边框
  @Prop leftIcon: ResourceStr = $r('app.media.ic_common_back') // 左边图标
  @Prop rightIcon: ResourceStr = $r('sys.media.ohos_ic_public_more') // 右边图标
  @Prop showRightIcon: boolean = true // 是否显示右边图标
  onLeftClick: () => void = () => {} // 左侧点击事件
  onRightClick: () => void = () => {} // 右侧点击事件

  build() {
    Row({ space: 16 }) {
      Image(this.leftIcon)
        .size({ width: 24, height: 24 })
        .fillColor($r('app.color.black'))
        .onClick(() => {
          this.onLeftClick && this.onLeftClick()
          // if (this.onLeftClick) {
          //   this.onLeftClick()
          // }
        })
      Row() {
        if (this.title) {
          Text(this.title)
            .fontWeight(600)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .height(56)
      .layoutWeight(1)

      if (this.showRightIcon) {
        Image(this.rightIcon)
          .size({ width: 24, height: 24 })
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.onRightClick && this.onRightClick()
          })
      } else {
        Blank()
          .width(24)
      }
    }
    .padding({ left: 16, right: 16, top: this.topHeight })
    .height(56 + this.topHeight)
    .width('100%')
    .border({
      width: { bottom: this.showBorder ? 0.5 : 0 },
      color: $r('app.color.common_gray_bg')
    })
  }
}