import { Constants, NetworkUtil } from "basic"
import { FilterButton, QuestionListComponent } from "."
import { QuestionType } from "../models"

@Component
export struct HomePageCategory {
  @State QuestionTypeList: QuestionType[] = [] // 数据源
  @State isShowSheet: boolean = false // 显示筛选半模态
  @State filterDataIndex: number = 0 // 过滤分类 默认选中第一个

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
      Tabs() {
        ForEach(this.QuestionTypeList, (item: QuestionType) => {
          TabContent() {
            QuestionListComponent({typeId: item.id}) // 试题列表组件
          }
          .tabBar(
            // 滚动跟随的模式
            new SubTabBarStyle(item.name)
              .indicator({
                color: $r("app.color.black"),
                width: 24,
                height: 4,
                borderRadius: 2
              })
              .labelStyle({
                selectedColor: $r("app.color.black"),
                unselectedColor: $r("app.color.common_gray_01")
              })
          )
        })
      }.barMode(BarMode.Scrollable) // 允许页签左右滑动
      Row() {
        Image($r('app.media.ic_home_filter'))
          .width(24)
          .aspectRatio(1)
      }
      .height(56)
      .justifyContent(FlexAlign.Center)
      .linearGradient({ angle: 90, colors: [['#00FFFFFF', 0], ['#FFFFFF', 0.285]] })
      .bindSheet($$this.isShowSheet, this.FilterSheetBuilder(), {
        showClose: false,
        height: 500
      })
      .onClick(() => this.isShowSheet = true)
    }
  }

  // 半模态容器
  @Builder FilterSheetBuilder() {
    Column() {
      Row() {
        Text('重置')
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_03'))
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
      }
      .margin({ bottom: 4, top: 4 })

      Text('题目排序').textTitle()
      Flex() {
        FilterButton({ label: '默认' })
        FilterButton({ label: '浏览量', isSort: true })
        FilterButton({ label: '难度', isSort: true })
        FilterButton({ label: '推荐' })
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