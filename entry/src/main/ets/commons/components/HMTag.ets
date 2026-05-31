import { HMTagInfo } from "../../models";

@Component
export struct HMTag {
  @Prop difficulty: number
  @Prop text: string = '默认'
  @Prop color: ResourceColor = $r('app.color.common_green')

  build() {
    Text(infoMap[this.difficulty]?.text || this.text)
      .fontColor(infoMap[this.difficulty]?.color || this.color)
      .padding({ left: 6, right: 6 })
      .fontSize(10)
      .height(18)
      .constraintSize({ minWidth: 34 })
      .borderRadius(2)
      .backgroundColor($r('app.color.common_gray_bg'))
      .textAlign(TextAlign.Center)
  }
}

const infoMap: Record<number, HMTagInfo> = {
  1: { text: "简单", color: $r("app.color.common_green") },
  2: { text: "简单", color: $r("app.color.common_green") },
  3: { text: "一般", color: $r("app.color.common_blue") },
  4: { text: "一般", color: $r("app.color.common_blue") },
  5: { text: "困难", color: $r("app.color.common_main_color") },
};