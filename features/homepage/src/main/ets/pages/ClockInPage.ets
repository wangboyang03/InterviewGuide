import { HmCalendar, HmCalendarSelectedDay } from '@ohmos/calendar'
import { ClockInPageRequest, ClockInPageResponse, Constants, NavigationBar, NetworkUtil } from 'basic'

interface DayBuilderParams {
  day: number
  text: string
}

@Entry
@Component
struct ClockInPage {
  @State clickInInformation: ClockInPageResponse = {
    clockinNumbers: 0,
    totalClockinNumber: 0,
    clockins: []
  }
  @State seletedDays: HmCalendarSelectedDay[] = []

  aboutToAppear(): void {
    const currentDate = new Date()
    this.getClockInResponse({
      year: String(currentDate.getFullYear()),
      month: String(currentDate.getMonth() + 1),
    })
  }

  /**
   * 获取打卡信息
   */
  async getClockInResponse(params: ClockInPageRequest) {
    const result = await NetworkUtil.getInstance().request<ClockInPageResponse>({
      url: Constants.CLOCK_IN_INFO,
      params
    })
    this.clickInInformation = result
    this.seletedDays = result.clockins.map(item => ({date: item.createdAt} as HmCalendarSelectedDay))
  }

  build() {
    Column({ space: 16 }) {
      // 导航条
      NavigationBar({ title: '每日打卡', showRightIcon: false })
      Row() {
        this.dayBuilder({ day: this.clickInInformation.totalClockinNumber, text: '累计打卡' })
        this.dayBuilder({ day: this.clickInInformation.clockinNumbers, text: '连续打卡' })
      }
      .padding({
        top: 10,
        bottom: 25,
        left: 16,
        right: 16
      })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row() {
        HmCalendar({
          selectedDays: this.seletedDays
        })
          .borderRadius(8)
          .border({ width: 0.5, color: '#ededed' })
          .shadow({ color: '#ededed', radius: 16 })
          .backgroundColor($r('app.color.white'))
      }
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.clocked_bg'))
    .backgroundImageSize({ width: '100%' })
  }

  @Builder
  dayBuilder(params: DayBuilderParams) {
    Column() {
      Row() {
        Text(params.day.toString())
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
        Text('天')
          .fontSize(10)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ bottom: 8, left: 10 })
      }
      .alignItems(VerticalAlign.Bottom)

      Text(params.text)
        .fontSize(10)
        .fontColor($r('app.color.common_gray_01'))
    }.margin({ right: 36 })
  }
}