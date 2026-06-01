@Component
export struct FilterButton {
  @Prop label: string;
  @Prop isSetBadge: boolean;
  @Prop isSort: boolean;

  build() {
    Row() {
      Text(this.label)
        .fontSize(12)
        .fontColor($r('app.color.black'))
      if (this.isSetBadge) {
        Image($r('app.media.ic_home_new'))
          .width(32)
          .height(14)
          .objectFit(ImageFit.Contain)
          .position({ right: -26, top: -7 })
      }
      if (this.isSort) {
        Column() {
          Image($r('sys.media.ohos_ic_public_arrow_up'))
            .size({ width: 12, height: 6 })
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .size({ width: 12, height: 6 })
        }
        .margin({ top: -0.5, left: 2 })
      }
    }
    .height(30)
    .padding({ left: 10, right: 10 })
    .backgroundColor($r('app.color.common_gray_bg'))
    .borderRadius(4)
    .margin({ top: 12, right: this.isSetBadge ? 26 : 10 })
  }
}