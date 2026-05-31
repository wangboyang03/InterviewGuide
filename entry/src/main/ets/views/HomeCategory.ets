import axios, { AxiosError, AxiosResponse } from "@ohos/axios";
import { HMFilterButton, HMQuestionItem, HMQuestionList } from "../commons/components";
import { HMTag } from "../commons/components/HMTag";
import { hmHttp, hmLogger } from "../commons/utils";
import { QuestionType } from "../models";

interface Res {
  code: number
  message: string
  data: QuestionType[]
}

@Component
export struct HomeCategory {
  @State questionTypeList: QuestionType[] = []
  @State activeIndex: number = 0
  // 控制半模态弹窗的显示和隐藏
  @State isShow: boolean = false

  aboutToAppear(): void {
    this.getQuestionTypeList()
  }

  /**
   * 获取分类
   */
  async getQuestionTypeList() {
    const res = await hmHttp.request<QuestionType[]>({ url: 'question/type' })
    this.questionTypeList = res
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Tabs({ index: $$this.activeIndex }) {
        ForEach(this.questionTypeList, (item: QuestionType, i) => {
          TabContent() {
            HMQuestionList({ typeId: item.id })
          }
          .tabBar(this.TabBarBuilder(item, i))
        })
      }
      .barHeight(44)
      .barMode(BarMode.Scrollable)
      .scrollable(false)
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_border') })

      // 右侧筛选图标
      Row() {
        Image($r('app.media.ic_home_filter'))
          .width(24)
          .aspectRatio(1)
      }
      .width(56)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .linearGradient({ angle: 90, colors: [['#00FFFFFF', 0], ['#FFFFFF', 0.285]] })
      .bindSheet($$this.isShow, this.FilterSheetBuilder(), { height: 400, showClose: false })
      .onClick(() => {
        this.isShow = true
      })
    }
  }

  @Builder
  TabBarBuilder(item: QuestionType, index: number) {
    Row() {
      // 左侧
      Stack({ alignContent: Alignment.Bottom }) {
        Text(item.name)
          .fontSize(15)
          .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_01'))
          .height(44)

        Text()
          .backgroundColor($r('app.color.black'))
          .width(this.activeIndex === index ? 20 : 0)
          .height(2)
          .animation({
            duration: 300
          })
      }

      // 右侧
      if (item.displayNewestFlag) {
        Image($r('app.media.ic_home_new'))
          .width(32)
          .height(14)
          .margin({ left: 4 })
          .objectFit(ImageFit.Contain)
      }
    }
    .padding({ left: 16, right: index === this.questionTypeList.length - 1 ? 50 : 0 })
  }

  /**
   * 半模态弹层的结构
   */
  @Builder
  FilterSheetBuilder() {
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

      Text('题目排序')
        .textTitle()
      // 筛选按钮
      Flex({ wrap: FlexWrap.Wrap }) {
        HMFilterButton({ text: '默认' })
        HMFilterButton({ text: '浏览量', isSort: true })
        HMFilterButton({ text: '难度', isSort: true })
        HMFilterButton({ text: '推荐' })
      }

      Text('选择分类')
        .textTitle()
      // 选择分类
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.questionTypeList, (item: QuestionType) => {
          HMFilterButton({
            text: item.name,
            isNew: item.displayNewestFlag === 1,
          })
        })
      }
    }
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .height('100%')
  }
}

@Extend(Text)
function textTitle() {
  .fontSize(14)
  .fontWeight(500)
  .fontColor($r('app.color.black'))
  .width('100%')
  .margin({ top: 20 })
}