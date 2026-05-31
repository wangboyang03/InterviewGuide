import { HMClockIn, HMSearchBox } from "../commons/components"
import { HomeCategory } from "../views/HomeCategory"

@Component
export struct HomePage {
  build() {
    Column() {
      // 1. 导航组件
      HMSearchBox() {
        HMClockIn({ clockInCount: 10 })
      }

      // 2. 轮播图
      this.SwiperItemBuilder()

      // 3. 试题选项
      Column() {
        HomeCategory()
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.white'))

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_gray_bg'))
  }

  @Builder
  SwiperItemBuilder() {
    Swiper() {
      ForEach(
        [$r('app.media.banner_ai'), $r('app.media.banner_pj'), $r('app.media.banner_qa')],
        (item: ResourceStr) => {
          Row() {
            Image(item)
              .width('100%')
              .aspectRatio(2.65)
              .objectFit(ImageFit.Fill)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        })
    }
    .autoPlay(true)
    .indicator(
      DotIndicator
        .dot()
        .bottom(4)
        .itemHeight(4)
        .selectedItemHeight(4)
        .selectedColor($r('app.color.white'))
    )
    .margin({
      bottom: 16
    })
  }
}