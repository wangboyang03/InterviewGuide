import { Auth, Constants, Logger, NetworkUtil, PAGE_PATH } from "basic"
import { PageData, QuestionItem, QuestionListRequest, QuestionPageResponse, SortType } from "../models"
import { QuestionItemComponent } from "./QuestionItemComponent"

@Component
export struct QuestionListComponent {
  @State refreshing: boolean = false // 正在刷新中
  @State refreshState: RefreshStatus = RefreshStatus.Inactive // 刷新状态
  @State loading: boolean = false // 正在加载数据
  @State isFinished: boolean = false // 全部加载完毕
  @Prop typeId: number // 试题ID
  @Prop @Watch('onChangeSort') sort: SortType = SortType.Default // 排序方式 默认
  @State page: number = 1
  @State questionList: QuestionItem[] = [] // 试题列表

  getDisplayText() {
    switch (this.refreshState) {
      case RefreshStatus.Inactive:
        return ""
      case RefreshStatus.Drag:
        return "继续下拉"
      case RefreshStatus.OverDrag:
        return "松手刷新"
      case RefreshStatus.Refresh:
        return "刷新中"
      case RefreshStatus.Done:
        return "刷新完成"
      default:
        return ""
    }
  }

  getQuestionList(): Promise<PageData<QuestionItem>> {
		return NetworkUtil.getInstance().request<PageData<QuestionItem>>({
      url: Constants.QUESTION_LIST,
      params: {
        type: this.typeId,
        questionBankType: 10,
        sort: this.sort,
        page: this.page,
        pageSize: 10
      } as QuestionListRequest
    })
	}

  async onLoad() {
    const result = await this.getQuestionList()
    this.questionList.push(...result.rows)
    this.loading = false
    if (this.page >= result.pageTotal) {
      this.isFinished = true // 列表全部加载完毕
    } else {
      this.page++
    }
  }

  async onRefresh() {
    try {
      this.page = 1 // 从头开始请求
      const result = await this.getQuestionList()
      this.questionList = result?.rows
      this.refreshing = false
      if (this.page >= result.pageTotal) {
        this.isFinished = true
      } else {
        this.isFinished = false
        this.page++
      }
      this.getUIContext().getPromptAction().showToast({ message: '刷新完成' })
    } catch (error) {
      Logger.error(JSON.stringify(error))
    } finally {
      this.loading = false
      this.refreshing = false
    }
  }

  onChangeSort() {
    this.refreshing = true
  }

  build() {
    Refresh({ refreshing: $$this.refreshing, builder: this.getRefreshBuilder() }) {
      List() {
        ForEach(this.questionList, (item: QuestionItem, _:number) => {
          ListItem() {
            QuestionItemComponent({item: item}).onClick(() => {
              Auth.getInstance().checkAuth({
                url: PAGE_PATH.QUESTION_PAGE,
                params: {
                  item
                } as QuestionPageResponse
              })
            })
          }
        })
        this.getBottomDisplay() // 放在底部的提示
      }
      .divider({
        color: $r("app.color.common_gray_border"),
        strokeWidth: 0.5,
        startMargin: 16,
        endMargin: 16
      })
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST, // 向上滚动 父组件优先
        scrollBackward: NestedScrollMode.SELF_FIRST // 向下滚动 子组件优先
      })
      .onReachEnd(() => {
        if (this.refreshing || this.loading || this.isFinished) {
          // 边界判断
          return;
        }
        this.loading = true
        this.onLoad()
      })
    }
    .onRefreshing(()=> this.onRefresh()) // 下拉刷新
  }

  /**
   * 下拉刷新指示器
   */
  @Builder getRefreshBuilder() {
    Row({ space: 10 }) {
      Text(this.getDisplayText())
        .fontSize(12)
        .fontColor($r("app.color.common_gray_01"))
      LoadingProgress()
        .width(20)
        .aspectRatio(1)
        .color($r("app.color.common_gray_01"))
    }
    .width("100%")
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 上拉加载指示器
   */
  @Builder getBottomDisplay() {
    ListItem() {
      Row({ space: 10 }) {
        if (this.isFinished) {
          Text("没有数据了")
            .fontSize(12)
            .fontColor($r("app.color.common_gray_01"))
        } else if (this.loading) {
          Text("正在加载中")
            .fontSize(12)
            .fontColor($r("app.color.common_gray_01"))
          LoadingProgress()
            .width(20)
            .aspectRatio(1)
            .color($r("app.color.common_gray_01"))
        }
      }
      .width("100%")
      .height(50)
      .justifyContent(FlexAlign.Center)
    }
  }
}