@Component
export struct ClockSignIn {
  @Prop clockInCount: number = 1

  /**
   * 获取背景图
   */
  getBackgroundImage() {
    if (this.clockInCount) {
      return $r("app.media.ic_common_clocked") // 打勾
    }
    return $r("app.media.ic_common_unclock")
  }

  build() {
    Row() {
      if (this.clockInCount) {
        // 显示连续打卡
        Column() {
          Text("已连续打卡").fontSize(8)
          Text() {
            Span(this.clockInCount.toString())
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
            Span("天").fontSize(12)
          }
        }
        .margin({left: 30})
      } else {
      Text("打卡")
        .fontWeight(FontWeight.Bold)
        .margin({
          left: 30,
          top: -4
        })
      }
    }
    .width(74)
    .height(28)
    .backgroundImage(this.getBackgroundImage())
    .backgroundImageSize(ImageSize.Contain)
  }
}