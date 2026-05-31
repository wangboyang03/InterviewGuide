import { GlobalVariable } from "../constants"

@Component
export struct HMSearchBox {
  @StorageProp(GlobalVariable.SAFE_TOP_HEIGHT) topHeight: number = 0
  @Prop boxHeight: Length = 32
  @Prop ph: string = '搜索题目'
  @Prop phColor: ResourceColor = $r('app.color.common_gray_02')
  @Prop layoutWeightValue: number = 1
  @BuilderParam
  default: () => void = this.defaultBuilder

  @Builder
  defaultBuilder() {
  }

  build() {
    Row({ space: 16 }) {
      // 1. 左侧扫码
      Image($r('app.media.ic_home_scan'))
        .width(24)
        .aspectRatio(1)
      // 2. 拟搜索框
      Row({ space: 5 }) {
        Image($r('app.media.ic_common_search'))
          .width(14)
          .height(14)
          .fillColor(this.phColor)
        Text(this.ph)
          .fontSize(14)
          .fontColor(this.phColor)
      }
      .backgroundColor($r('app.color.common_gray_border'))
      .borderRadius(10)
      .layoutWeight(this.layoutWeightValue)
      .height(this.boxHeight)
      .justifyContent(FlexAlign.Center)

      // 3. 打卡组件
      this.default()
    }
    .width('100%')
    .height(64 + this.topHeight)
    .padding({ left: 16, right: 16, top: this.topHeight })
  }
}