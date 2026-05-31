import { QuestionTag } from "basic"

@Component
export struct QuestionItem {
  build() {
    Column({ space: 10 }) {
      Row({ space: 5 }) {
        QuestionTag()
        Text('1+1=?')
          .fontSize(15)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(500)
      }
      .width('100%')

      RowSplit() {
        Text('点赞 0')
          .grayText(true)
        Text('浏览 0')
          .grayText()
        Text('看过')
          .grayText()
      }
    }
    .padding({ left: 16, right: 16 })
    .width('100%')
    .height(80)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }
}

@Extend(Text) function grayText(isStart: boolean = false) {
  .lineHeight(13)
  .fontSize(13)
  .fontColor($r('app.color.common_gray_01'))
  .padding({ left: isStart ? 0 : 12, right: 12 })
}