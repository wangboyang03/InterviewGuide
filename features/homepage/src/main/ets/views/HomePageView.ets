import { BasicTool, ClockSignIn, Constants, SearchBox, UserResponse } from "basic"
import { HomePageCategory } from "../components"

@Component
export struct HomePageView {
  @StorageProp(Constants.SAFE_TOP_HEIGHT_KEY) topHeight: number = 0
  @StorageProp(Constants.USER_STORAGE_KEY) user: UserResponse = {} as UserResponse
  banners: ResourceStr[] = [
    $r("app.media.banner_qa"),
    $r("app.media.banner_pj"),
    $r("app.media.banner_ai")
  ] // 轮播图数据

  build() {
    // Text('面试通首页')
    Scroll() {
      Column() {
        SearchBox() {
          ClockSignIn({
            clockInCount: this.user.clockinNumbers
          }).onClick(() => BasicTool.getInstance().getClockInNumber()) // 签到组件
        } // 搜索框组件

        this.getSwiperBuilder() // 轮播图

        this.getQuestionBuilder() // 试题分类
      }
      .width("100%")
      .height("100%")
      .padding({
        top: this.topHeight
      })
    }
    .scrollBar(BarState.Off)
  }

  /**
   * 轮播图容器
   */
  @Builder getSwiperBuilder() {
    Swiper() {
      ForEach(this.banners, (item: ResourceStr) => {
        Row() {
          Image(item)
            .width("100%")
            .aspectRatio(2.65)
            .objectFit(ImageFit.Fill)
        }
        .padding({
          left: 16,
          right: 16
        })
        .width("100%")
      })
    }
    .autoPlay(true)
    .indicator(
      // 轮播图指示器
      DotIndicator.dot()
        .bottom(10)
        .itemHeight(4)
        .selectedItemWidth(30)
        .selectedColor($r("app.color.white"))
    )
  }

  /**
   * 试题分类容器
   */
  @Builder getQuestionBuilder() {
    Column() {
      HomePageCategory()
    }
    .width("100%")
    .layoutWeight(1)
    .backgroundColor($r("app.color.white"))
  }
}