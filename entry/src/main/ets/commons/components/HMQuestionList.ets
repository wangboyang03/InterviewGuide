import { HMQuestionItem } from "."
import { PageData, QuestionItem, QuestionListParams, SortType } from "../../models"
import { hmHttp } from "../utils"

@Component
export struct HMQuestionList {
  @Prop typeId: number // 分类id
  @Prop sort: SortType = SortType.Default // 排序方式
  @State isRefreshing: boolean = false // 下拉
  @State isLoading: boolean = false // 上拉（是否正在加载）
  @State isFinished: boolean = false // 是否全部加载完毕
  @State list: QuestionItem[] = []
  @State page: number = 1

  /**
   * 下拉刷新
   */
  async onRefresh() {
    // 1. 请求数据
    this.page = 1
    const res = await this.getQuestionList()
    this.list = res.rows
    // 2. 关闭刷新状态
    this.isRefreshing = false
    // 3. 判断是否有下一页
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.page++
      this.isFinished = false
    }
    // 4. 轻提示
    this.getUIContext().getPromptAction().showToast({ message: '已获取最新数据' })
  }

  /**
   * 上拉加载
   */
  async onLoad() {
    const res = await this.getQuestionList()
    this.list.push(...res.rows)
    this.isLoading = false
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.page++
    }
  }

  /**
   * 获取试题列表
   */
  getQuestionList(): Promise<PageData<QuestionItem>> {
    return hmHttp.request<PageData<QuestionItem>>({
      url: 'question/list',
      params: {
        type: this.typeId,
        questionBankType: 10,
        sort: this.sort,
        page: this.page,
        pageSize: 10
      } as QuestionListParams
    })
  }

  build() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List() {
        ForEach(this.list, (item: QuestionItem) => {
          ListItem() {
            HMQuestionItem({
              item
            })
          }
        })
        // 底部提示
        this.LoadMoreBuilder()
      }
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_01'),
        startMargin: 10,
        endMargin: 10
      })
      .edgeEffect(EdgeEffect.None) // 关闭弹性效果
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .onReachEnd(() => {
        // 边界判断
        if (this.isRefreshing || this.isLoading || this.isFinished) {
          return
        }
        // 修改状态
        this.isLoading = true
        // 调用方法
        this.onLoad()
      })
    }
    .onRefreshing(() => {
      this.onRefresh()
    })
  }

  /**
   * 底部提示
   */
  @Builder
  LoadMoreBuilder() {
    ListItem() {
      if (this.isFinished) {
        Row() {
          Text('没有更多了')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.isLoading) {
        Row({ space: 5 }) {
          LoadingProgress()
            .width(20)
          Text('正在加载中...')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .height(80)
  }
}