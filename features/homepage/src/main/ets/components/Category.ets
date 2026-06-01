import { Constants, NetworkUtil } from "basic"
import { QuestionList } from "."
import { QuestionType } from "../models"

@Component
export struct HomePageCategory {
  @State QuestionTypeList: QuestionType[] = [] // 数据源

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
    Tabs() {
      ForEach(this.QuestionTypeList, (item: QuestionType) => {
        TabContent() {
          QuestionList() // 试题列表组件
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
  }
}