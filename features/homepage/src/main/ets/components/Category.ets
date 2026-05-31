import { QuestionList } from "."
import { QuestionType } from "../models"

@Component
export struct HomePageCategory {
  @State list: QuestionType[] = [
    { id: 1, name: 'ArkTS', displayNewestFlag: 0 },
    { id: 2, name: 'ArkUI', displayNewestFlag: 1 },
    { id: 3, name: 'Hap', displayNewestFlag: 1 },
    { id: 4, name: 'Hsp', displayNewestFlag: 0 },
    { id: 5, name: 'Har', displayNewestFlag: 0 },
    { id: 6, name: 'Ability', displayNewestFlag: 0 },
    { id: 7, name: 'Stage', displayNewestFlag: 0 },
    { id: 8, name: 'Kit', displayNewestFlag: 0 }
  ] // 数据源

  build() {
    Tabs() {
      ForEach(this.list, (item: QuestionType) => {
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