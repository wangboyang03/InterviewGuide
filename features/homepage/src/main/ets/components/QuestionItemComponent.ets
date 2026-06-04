import { HighlightLabelStyle, QuestionItem, QuestionTag } from "basic"

@Component
export struct QuestionItemComponent {
  @Prop item: QuestionItem = {} as QuestionItem
  @Prop includeKeywordList: HighlightLabelStyle[] = []
  @Prop textColorWithKeyWord: ResourceColor = '#ffff0000'

  build() {
    Column({ space: 10 }) {
      Row({ space: 5 }) {
        QuestionTag({ difficulty: this.item.difficulty }) // 传入试题难度标签
        this.buildHeightLightText()
      }
      .width('100%')

      RowSplit() {
        Text(`点赞 ${this.item.likeCount}`)
          .grayText(true)
        Text(`浏览 ${this.item.views}`)
          .grayText()
        Text(this.item.readFlag ? "已看过" : "未看过")
          .grayText()
      }
    }
    .padding({ left: 16, right: 16 })
    .width('100%')
    .height(80)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildHeightLightText() {
    Text() {
      ForEach(this.includeKeywordList, (item: HighlightLabelStyle) => {
        Span(item.text)
          .fontColor(item.needHighLight ? this.textColorWithKeyWord : Color.Black)
          .textBackgroundStyle({
            color: item.needHighLight ? Color.Yellow : Color.Transparent,
          })
      })
    }
      .fontSize(15)
      .layoutWeight(1)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .fontWeight(500)
  }
}

@Extend(Text) function grayText(isStart: boolean = false) {
  .lineHeight(13)
  .fontSize(13)
  .fontColor($r('app.color.common_gray_01'))
  .padding({ left: isStart ? 0 : 12, right: 12 })
}