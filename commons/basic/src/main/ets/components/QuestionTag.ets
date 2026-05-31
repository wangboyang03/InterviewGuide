import { AllTagInformation } from "../models"

@Component
export struct QuestionTag {
  @Prop difficulty: number = -1

  build() {
    Text(AllTagInformation[this.difficulty]?.text ?? "未知")
      .fontColor(AllTagInformation[this.difficulty]?.color ?? $r("app.color.black"))
      .fontSize(10)
      .padding({ left: 6, right: 6 })
      .height(18)
      .constraintSize({ minWidth: 34 }) // 元素最小宽度
      .borderRadius(2)
      .backgroundColor($r('app.color.common_gray_bg'))
      .textAlign(TextAlign.Center)
  }
}