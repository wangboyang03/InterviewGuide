import { Constants, NetworkUtil } from "basic"
import { FilterButton, QuestionListComponent } from "."
import { QuestionType, SortType } from "../models"

@Component
export struct HomePageCategory {
  @State QuestionTypeList: QuestionType[] = [] // 数据源
  @State isShowSheet: boolean = false // 显示筛选半模态
  @State filterDataIndex: number = 0 // 过滤分类 默认选中第一个
  @State filterDataSort: SortType = SortType.Default // 过滤排序 默认选中默认
  @State activatedIndex: number = 0 // 试题分类TabBar选中索引 默认第一个
  @State Sort: SortType = SortType.Default // 排序方式 默认

  aboutToAppear(): void {
    this.getQuestionTypeList()
  }

  async getQuestionTypeList() {
    const result = await NetworkUtil.getInstance().request<QuestionType[]>({
      url: Constants.QUESTION_TYPE
    })
    // this.getUIContext().getPromptAction().showToast({ message: JSON.stringify(result)})
    this.QuestionTypeList = result
  }

  build() {
    Stack({alignContent: Alignment.TopEnd}) {
      Tabs({index: $$this.activatedIndex}) {
        ForEach(this.QuestionTypeList, (item: QuestionType, index) => {
          TabContent() {
            QuestionListComponent({typeId: item.id, sort: this.Sort}) // 试题列表组件
          }
          .tabBar(this.TabBarBuilder(item, index))
        })
      }
      .barHeight(44)
      .barMode(BarMode.Scrollable) // 允许页签左右滑动
      .scrollable(false)
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_border') })

      Row() {
        Image($r('app.media.ic_home_filter'))
          .width(24)
          .aspectRatio(1)
      }
      .height(44)
      .justifyContent(FlexAlign.Center)
      .linearGradient({ angle: 90, colors: [['#00FFFFFF', 0], ['#FFFFFF', 0.285]] })
      .bindSheet($$this.isShowSheet, this.FilterSheetBuilder(), {
        showClose: false,
        height: 500
      })
      .onClick(() => {
        this.isShowSheet = true
        this.filterDataIndex = this.activatedIndex
      })
    }
  }

  @Builder TabBarBuilder(item: QuestionType, index: number) {
    Row() {
      Stack({ alignContent: Alignment.Bottom }){
        Text(item.name)
          .fontSize(15)
          .fontColor(this.activatedIndex == index ? $r('app.color.black') : $r('app.color.common_gray_01'))
          .height(44)
        Text()
          .width(this.activatedIndex == index ? 20 : 0)
          .height(2)
          .backgroundColor($r('app.color.black'))
          .animation({ duration: 300 })
      }
      if (item.displayNewestFlag == 1) {
        Image($r('app.media.ic_home_new'))
          .width(32)
          .height(14)
          .objectFit(ImageFit.Contain)
          .margin({ left: 4 })
      }
    }
    .padding({ left: 16, right: this.QuestionTypeList.length == index + 1 ? 16 : 0 })
  }

  // 半模态容器
  @Builder FilterSheetBuilder() {
    Column() {
      Row() {
        Text('重置')
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_03'))
          .onClick(() => {
            this.filterDataIndex = 0
            this.filterDataSort = SortType.Default
          })
        Text('筛选题目')
          .layoutWeight(1)
          .fontSize(18)
          .fontWeight(500)
          .fontColor($r('app.color.black'))
          .textAlign(TextAlign.Center)
        Text('完成')
          .fontWeight(500)
          .fontSize(16)
          .fontColor($r('app.color.common_main_color'))
          .onClick(() => {
            this.isShowSheet = false
            this.activatedIndex = this.filterDataIndex
            this.Sort = this.filterDataSort
          })
      }
      .margin({ bottom: 4, top: 4 })

      Text('题目排序').textTitle()
      Flex() {
        FilterButton({ label: '默认', selected: this.filterDataSort == SortType.Default }).onClick(() => this.filterDataSort = SortType.Default)
        FilterButton({ label: '浏览量', isSort: true, selected: (this.filterDataSort == SortType.ViewLow || this.filterDataSort == SortType.ViewHigh), sort: this.filterDataSort })
          .onClick(() => {
            if (this.filterDataSort == SortType.ViewLow || this.filterDataSort == SortType.ViewHigh) {
              this.filterDataSort = this.filterDataSort == SortType.ViewLow ? SortType.ViewHigh : SortType.ViewLow // 选中默认是降序 此时是降序就赋为升序
            } else {
              this.filterDataSort = SortType.ViewLow
            }
          })
        FilterButton({ label: '难度', isSort: true, selected: (this.filterDataSort == SortType.DifficultyLow || this.filterDataSort == SortType.DifficultyHigh), sort: this.filterDataSort })
          .onClick(() => {
            if (this.filterDataSort == SortType.DifficultyLow || this.filterDataSort == SortType.DifficultyHigh) {
              this.filterDataSort = this.filterDataSort == SortType.DifficultyLow ? SortType.DifficultyHigh : SortType.DifficultyLow // 选中默认是降序 此时是降序就赋为升序
            } else {
              this.filterDataSort = SortType.DifficultyLow
            }
          })
        FilterButton({ label: '推荐', selected: this.filterDataSort == SortType.Commend }).onClick(() => this.filterDataSort = SortType.Commend)
      }

      Text('选择分类').textTitle()
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.QuestionTypeList, (item: QuestionType, index) => {
          FilterButton({ label: item.name, isSetBadge: item.displayNewestFlag == 1, selected: this.filterDataIndex == index })
            .onClick(()=> this.filterDataIndex = index)
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor($r('app.color.white'))
  }
}

@Extend(Text) function textTitle() {
  .fontSize(14)
  .fontWeight(500)
  .fontColor($r('app.color.black'))
  .width('100%')
  .margin({ top: 20 })
}