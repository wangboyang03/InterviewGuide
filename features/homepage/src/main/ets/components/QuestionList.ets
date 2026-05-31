import { QuestionItemComponent } from "./QuestionItem"

@Component
export struct QuestionList {
  @State refreshing: boolean = false // 正在刷新中
  @State refreshState: RefreshStatus = RefreshStatus.Inactive // 刷新状态
  @State loading: boolean = false // 是否正在加载数据
  @State isFinished: boolean = true // 是否全部加载完毕

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

  onLoad() {}

  build() {
    Refresh({ refreshing: $$this.refreshing }) {
      Refresh({ refreshing: $$this.refreshing, builder: this.getRefreshBuilder() }) {
        List() {
          ForEach(Array.from(Array(10)), () => {
            ListItem() {
              QuestionItemComponent({
                item: {
                  id: '1',
                  difficulty: 5,
                  stem: '1+1=?',
                  likeCount: 100,
                  views: 10,
                  readFlag: 1
                }
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
        .scrollBar(BarState.Off)
        .onReachEnd(async () => {
          if (!this.loading && !this.isFinished) {
            this.loading = true
            await this.onLoad()
            this.loading = false // 便于下次请求
          }
        })
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST, // 向上滚动 父组件优先
          scrollBackward: NestedScrollMode.SELF_FIRST // 向下滚动 子组件优先
        })
      }
      .onStateChange((state) => {
        this.refreshState = state // 当前状态
        if (this.refreshState == RefreshStatus.Refresh) {
          // 执行刷新逻辑
          this.refreshing = false // 刷新完成
        }
      })
    }
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
        } else {
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