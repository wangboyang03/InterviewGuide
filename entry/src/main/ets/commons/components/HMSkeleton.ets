@Component
export struct HMSkeletonItem {
  @Prop widthValue: Length = '100%'
  @Prop heightValve: Length = '16'
  @Prop backgroundColorRes: ResourceStr = $r('app.color.common_gray_bg')

  build() {
    Text()
      .height(this.heightValve)
      .width(this.widthValue)
      .borderRadius(4)
      .backgroundColor(this.backgroundColorRes)
  }
}

@Component
export struct HMSkeleton {
  @State opacityValue: number = 1
  @BuilderParam default:()=> void = this.defaultBuilder

  build() {
    Row() {
      this.default()
    }
    .opacity(this.opacityValue)
    .animation({
      duration: 600, // 动画持续时间
      playMode:PlayMode.Alternate, // 动画先从起点到终点 再从终点回到起点 循环往复
      iterations: -1, // 无限循环
      curve:Curve.EaseInOut // 先慢到快再到慢
    })
    .onAppear(()=> this.opacityValue = 0.5)

  }

  @Builder defaultBuilder() {}
}