import { BasicTool, Constants, NavigationBar, NetworkUtil } from 'basic'
import { studyDataItem, studyDataList, StudyDataResponse } from '../models/study'

@Entry
@Component
struct StudyTimePage {
  @StorageLink(Constants.SAFE_BOTTOM_HEIGHT_KEY) bottomHeight: number = 0
  @State studyData: StudyDataResponse = {
    totalTime: 0,
    studyData: []
  }

  /**
   * 获取学习信息数据
   */
  async getStudyData() {
    const result = await NetworkUtil.getInstance().request<StudyDataResponse>({
      url: Constants.STUDY_INFO
    })
    this.studyData = result
  }

  /**
   * 将总数和占比转换为百分比
   */
  getPercentage(total: number, done: number): string {
    return `${Math.round((done / total) * 100)}%`
  }

  aboutToAppear(): void {
    this.getStudyData()
  }

  build() {
    Column() {
      NavigationBar({title: '学习数据', showRightIcon:false})
      /** 面板区域 **/
      Column() {
        Row({space: 5}) {
          Text('累计学习时长')
            .fontSize(14)
            .fontWeight(500)
            .fontColor($r('app.color.common_gray_03'))

          Image($r('sys.media.ohos_ic_public_clock'))
            .width(15)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
        }
        .width('100%')

        Text() {
          Span(BasicTool.getInstance().formatTimeFromSeconds(this.studyData.totalTime ?? 0).replace(/分钟|小时|天/, ''))
            .fontSize(45)
            .fontWeight(700)
          Span(BasicTool.getInstance().formatTimeFromSeconds(this.studyData.totalTime ?? 0).replace(/\d|\./g, ''))
            .padding({left: 10,bottom: 10})
        }
        .width('100%')
        .fontColor($r('app.color.common_green'))
      }
      .width('100%')
      .padding(10)
      Scroll() {
        Column() {
          // 知识点学习进度
          Text(this.studyData.studyData?.[0]?.type)
            .margin({ bottom: 10, top: 30 })
            .width('100%')
          GridRow({ columns: 2, gutter: 20 }) {
            ForEach(this.studyData.studyData?.[0]?.list, (item: studyDataList) => {
              this.ProgressBuilder(item.name, item.done, item.total)
            })
            GridCol({ span: 2 }) {
              Row({ space: 16 }) {
                this.DotBuilder('#87E0CD', true)
                this.DotBuilder('#87E0CD', false)
              }
              .margin({ top: 10 })
            }
          }
          .backgroundColor($r('app.color.white'))
          .padding(16)
          .borderRadius(8)
          .shadow({ color: $r('app.color.common_gray_border'), radius: 16 })

          // 项目学习进度
          Text(this.studyData.studyData?.[1]?.type)
            .margin({ bottom: 10, top: 30 })
            .width('100%')
          GridRow({ columns: 1, gutter: 20 }) {
            ForEach(this.studyData.studyData?.[1]?.list, (item: studyDataList) => {
              this.ProgressBuilder(item.name, item.done, item.total, '#C7B5ED')
            })
            GridCol() {
              Row({ space: 16 }) {
                this.DotBuilder('#C7B5ED', true)
                this.DotBuilder('#C7B5ED', false)
              }
              .margin({ top: 10 })
            }
          }
          .backgroundColor($r('app.color.white'))
          .padding(16)
          .borderRadius(8)
          .shadow({ color: $r('app.color.common_gray_border'), radius: 16 })
        }
        .padding(16)
        .margin({ bottom: this.bottomHeight })}
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.study_time_bg'))
    .backgroundImageSize({width: '100%'})
  }

  @Builder
  ProgressBuilder(title: string, done: number, total: number, color: string = '#87E0CD') {
    GridCol() {
      Column() {
        Row() {
          Text(title)
            .fontColor($r('app.color.common_gray_01'))
            .fontSize(14)
          Text(this.getPercentage(total, done))
            .fontColor($r('app.color.common_gray_01'))
            .fontSize(14)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 5 })

        Progress({ value: done, total: total })
          .color(color)
          .width('100%')
      }
    }
  }

  @Builder
  DotBuilder(color: string, isDark: boolean) {
    Row() {
      Text()
        .width(7)
        .aspectRatio(1)
        .borderRadius(4)
        .backgroundColor(isDark ? color : $r('app.color.common_gray_01'))
        .margin({ right: 4 })
      Text(isDark ? '已学占比' : '未学占比')
        .fontSize(12)
        .fontColor(isDark ? $r('app.color.common_gray_03') : $r('app.color.common_gray_01'))
    }
  }
}