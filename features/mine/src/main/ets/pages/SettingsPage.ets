import { Auth, NavigationBar, PAGE_PATH, UserResponse, Constants } from 'basic';
import { SettingsThemeDialog } from '../views';
import { bundleManager, ConfigurationConstant } from '@kit.AbilityKit';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';

export interface Tool {
  icon?: ResourceStr
  name: string
  value?: string
  onClick?: () => void,
  radius?: 0 | 1 | 2
}

@Entry
@Component
struct SettingsPage {
  openSelectedThemeDialog = new CustomDialogController({
    builder: SettingsThemeDialog(),
    alignment: DialogAlignment.Bottom
  })
  @StorageProp(Constants.THEME_COLOR_KEY) themeColor: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
  @State cacheSize: string = ''
  @State appVersion: string = '0.0.1'

  async computeCacheDir() {
    const res = await storageStatistics.getCurrentBundleStats()
    this.cacheSize = (res.cacheSize / (1000 * 1000)).toFixed(2) + 'MB'
  }

  clearCacheDir() {
    try {
      const context = AppStorage.get<Context>(Constants.GLOBAL_CONTEXT)
      if (context) {
        const cacheDir = context.cacheDir
        const res = fileIo.accessSync(cacheDir)
        if (res) {
          fileIo.rmdirSync(cacheDir)
        }
        const appContext = context.getApplicationContext()
        if (appContext) {
          const appCacheDir = appContext.cacheDir
          const res = fileIo.accessSync(appCacheDir)
          if (res) {
            fileIo.rmdirSync(appCacheDir)
          }
        }
      }
      this.computeCacheDir()
      this.getUIContext().getPromptAction().showToast({message:'缓存已清除'})
    } catch (error) {
      // 日志.
    }
  }

  async getAppVersion() {
    const res = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    this.appVersion = res.vendor
  }

  aboutToAppear(): void {
    this.computeCacheDir()
    this.getAppVersion()
  }

  build() {
    Column() {
      NavigationBar({ title: '设置', showRightIcon: false, showBorder: true })
      Column({ space: 0.5 }) {
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '编辑资料', radius: 1, onClick: () => {
            Auth.getInstance().checkAuth({url: PAGE_PATH.PROFILE_PAGE})
          }
        })
        this.toolsBuilder({ name: '账号设置', radius: 2 })
        Blank().height(15)
        this.toolsBuilder({ name: '消息推送', radius: 1 })
        this.toolsBuilder({
          name: '深色模式',
          value: this.themeColor == ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET ? '跟随系统' : this.themeColor == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ? '普通模式' : '深色模式',
          radius: 1,
          onClick: (): void => this.openSelectedThemeDialog.open()
        })
        this.toolsBuilder({
          name: '清除应用缓存', value: this.cacheSize, onClick: ():void => this.clearCacheDir()
        })
        this.toolsBuilder({ name: '当前版本', value: this.appVersion, radius: 2 })
        Blank().height(15)
        Text('退出账号')
          .height(50)
          .fontColor($r('app.color.common_main_color'))
          .opacity(0.6)
          .onClick(async () => {
            Auth.getInstance().setUser({} as UserResponse)
            this.getUIContext().getRouter().back()
          })
      }
      .layoutWeight(1)
      .padding({ right: 15, left: 15 })
      .backgroundColor($r('app.color.common_gray_bg'))
    }
  }

  @Builder toolsBuilder(tool: Tool) {
    Row() {
      if (tool.icon) {
        Image(tool.icon)
          .width(16)
          .aspectRatio(1)
          .margin({ right: 12 })
      }
      Text(tool.name)
        .fontSize(16)
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ right: 10 })
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(18)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .padding({ left: 16, right: 10 })
    .borderRadius({
      topLeft: tool.radius === 1 ? 8 : 0,
      topRight: tool.radius === 1 ? 8 : 0,
      bottomLeft: tool.radius === 2 ? 8 : 0,
      bottomRight: tool.radius === 2 ? 8 : 0
    })
    .onClick(() => {
      tool.onClick && tool.onClick()
    })
  }
}