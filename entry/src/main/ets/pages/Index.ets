import { GlobalVariable } from '../commons/constants'
import { HMAuth } from '../commons/utils/HMAuth'
import { TabItem } from '../models'
import { HomePage } from './HomePage'
import { InterviewPage } from './InterviewPage'
import { MinePage } from './MinePage'
import { ProjectPage } from './ProjectPage'

HMAuth.getInstance().initUser() // 初始化持久化存储

@Entry
@Component
struct Index {
  @StorageProp(GlobalVariable.SAFE_BOTTOM_HEIGHT) bottomHeight: number = 0
  tabList: TabItem[] = [
    {
      icon: $r('app.media.tabbar_home'),
      activeIcon: $r('app.media.tabbar_home_fill'),
      name: '首页'
    },
    {
      icon: $r('app.media.tabbar_project'),
      activeIcon: $r('app.media.tabbar_project_fill'),
      name: '项目'
    },
    {
      icon: $r('app.media.tabbar_interview'),
      activeIcon: $r('app.media.tabbar_interview_fill'),
      name: '面经'
    },
    {
      icon: $r('app.media.tabbar_mine'),
      activeIcon: $r('app.media.tabbar_mine_fill'),
      name: '我的'
    }
  ]
  @State activeIndex: number = 0

  build() {
    Column() {
      Tabs({ index: $$this.activeIndex }) {
        ForEach(this.tabList, (item: TabItem, index) => {
          TabContent() {
            if (index === 0) {
              HomePage()
            } else if (index === 1) {
              ProjectPage()
            } else if (index === 2) {
              InterviewPage()
            } else {
              MinePage()
            }
          }.tabBar(this.TabBarBuilder(item, index))
        })
      }
      .barPosition(BarPosition.End)
      .margin({ bottom: this.bottomHeight })
      .scrollable(false) // 禁用滚动
      .animationDuration(0) // 禁用动画
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  TabBarBuilder(item: TabItem, index: number) {
    Column({ space: 5 }) {
      Image(this.activeIndex === index ? item.activeIcon : item.icon)
        .width(24)
        .aspectRatio(1)
      Text(item.name)
        .fontSize(12)
        .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_01'))
    }
  }
}