import { QuestionItem, QuestionTag } from "basic"

@Component
export struct QuestionItemComponent {
  @Prop item: QuestionItem = {} as QuestionItem
  @Prop textColorWithKeyWord: ResourceColor = '#ffff0000'
  @Prop searchKeyWord: string = ""

  /**
   * 通过传入关键词 筛选包含关键词的文本并将需要高亮显示的返回
   */
  getHighLightText(keyword: string): string {
    if (!!keyword.trim()) {
      const stem = this.item.stem // 获取当前题目
      const result = []
      if (!!stem.includes(keyword)) {
        // 暂存。
      }
    }
		return ''
	}


  build() {
    Column({ space: 10 }) {
      Row({ space: 5 }) {
        QuestionTag({ difficulty: this.item.difficulty }) // 传入试题难度标签
        Text(this.item?.stem) // 题目
          .fontSize(15)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(500)
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
    Text(this.item?.stem) // 题目
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