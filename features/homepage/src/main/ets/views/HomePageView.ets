import { ClockSignIn, Constants, SearchBox } from "basic"

@Component
export struct HomePageView {
  @StorageProp(Constants.SAFE_TOP_HEIGHT_KEY) topHeight: number = 0
  build() {
    // Text('面试通首页')
    Column() {
      SearchBox() {
        ClockSignIn({
          clockInCount: 0
        }) // 签到组件
      } // 搜索框组件
    }
    .width("100%")
    .height("100%")
    .padding({
      top: this.topHeight
    })
  }
}