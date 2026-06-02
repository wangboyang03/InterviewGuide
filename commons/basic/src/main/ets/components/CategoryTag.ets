import { AllTagInformation } from "../models"

@Component
export struct CategoryTag {
  @Prop difficulty: number = 1 // 困难等级 1-2 3-4 -5
  @Prop tag: string
  @Prop tagColor: ResourceColor

  build() {
    Text(AllTagInformation[this.difficulty]?.text ?? this.tag)
      .fontColor(AllTagInformation[this.difficulty]?.color ?? this.tagColor)
      .fontSize(10)
      .padding({ left: 6, right: 6 })
      .height(18)
      .constraintSize({ minWidth: 34 })
      .borderRadius(2)
      .backgroundColor($r('app.color.common_gray_bg'))
      .textAlign(TextAlign.Center)
  }
}