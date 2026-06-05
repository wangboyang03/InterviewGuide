import { Constants, TabItem, TrackingPointUtil } from 'basic'
import { HomePageView } from 'homepage'
import { InterView } from 'interview'
import { MineView } from 'mine'
import { ProjectView } from 'project'

@Entry
@Component
struct Index {
  @State activatedIndex: number = 0 // 默认首页
  @StorageProp(Constants.SAFE_BOTTOM_HEIGHT_KEY) bottomHeight: number = 0
  tabBarList: TabItem[] = [
    {
      icon: $r('app.media.tabbar_home'),
      activeIcon: $r('app.media.tabbar_home_fill'),
      title: '首页',
      name: 'homepage'
    },
    {
      icon: $r('app.media.tabbar_project'),
      activeIcon: $r('app.media.tabbar_project_fill'),
      title: '项目',
      name: 'project'
    },
    {
      icon: $r('app.media.tabbar_interview'),
      activeIcon: $r('app.media.tabbar_interview_fill'),
      title: '面经',
      name: 'interview'
    },
    {
      icon: $r('app.media.tabbar_mine'),
      activeIcon: $r('app.media.tabbar_mine_fill'),
      title: '我的',
      name: 'mine'
    }
  ]

  aboutToAppear(): void {
    TrackingPointUtil.getInstance().report(true)
  }

  build() {
    Tabs({index: $$this.activatedIndex}) {
      // TabContent
      ForEach(this.tabBarList, (item: TabItem) => {
        TabContent() {
          if (item.name == 'homepage') {
            HomePageView()
          } else if (item.name == 'interview') {
            InterView()
          } else if (item.name == 'project') {
            ProjectView()
          } else {
            MineView()
          }
        }.tabBar(this.tabBarBuilder(item))
      })
    }
    .barPosition(BarPosition.End)
    .animationDuration(0)
    .padding({
      bottom: this.bottomHeight
    })
  }

  @Builder tabBarBuilder(item: TabItem) {
    Column({ space: 5 }) {
      Image(item.name == this.tabBarList[this.activatedIndex].name ? item.activeIcon : item.icon)
        .width(24)
        .aspectRatio(1)
      Text(item.title)
        .fontSize(12)
        .fontColor(item.name == this.tabBarList[this.activatedIndex].name ? $r("app.color.black") : $r("app.color.common_gray_01"))
    }
  }
}