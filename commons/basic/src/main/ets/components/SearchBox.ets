import { Auth } from "../utils"

@Component
export struct SearchBox {
  @Prop boxHeight: number = 32
  @Prop searchText: string = "搜索题目"
  @BuilderParam rightBuilder: () => void = this.defaultBuilder //插槽

  build() {
    Row({ space: 20 }) {
      Image($r("app.media.ic_home_scan")) // 扫一扫
        .width(24)
        .aspectRatio(1)
        .onClick(() => Auth.getInstance().checkAuth(() => this.getUIContext().getPromptAction().showToast({message:'可以扫码了'})))
      Row() {
        Image($r("app.media.ic_common_search"))
          .width(14)
          .aspectRatio(1)
          .fillColor($r("app.color.common_gray_01"))
        Text(this.searchText)
          .fontSize(14)
          .fontColor($r("app.color.common_gray_01"))
      }
      .layoutWeight(1)
      .height(this.boxHeight)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r("app.color.common_gray_bg"))
      .borderRadius(16)

      this.rightBuilder()
    }
    .padding({
      left: 16,
      right: 16
    })
    .width("100%")
    .height(64)
  }

  @Builder defaultBuilder() {}
}