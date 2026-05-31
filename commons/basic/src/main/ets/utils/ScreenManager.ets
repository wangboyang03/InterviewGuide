import { window } from "@kit.ArkUI";
import { Constants, Logger } from "../../../../Index";

export class ScreenManager {
  private static sInstance: ScreenManager;
  private mContext: Context | null = null
  private constructor() {} // 私有构造函数

  public static getInstance(): ScreenManager {
    if (!ScreenManager.sInstance) {
      ScreenManager.sInstance = new ScreenManager();
    }
    return ScreenManager.sInstance;
  }

  init(context: Context) {
    this.mContext = context
    return this
  }

  async fullScreen() {
    try {
      if (this.mContext) {
        // 获取当前应用的主窗口对象
        const windowObject = await window.getLastWindow(this.mContext)
        // 设置窗口为全屏模式
        await windowObject.setWindowLayoutFullScreen(true)

        // 获取顶部状态栏的高度，并转换为虚拟像素单位存储
        const topArea = windowObject.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        AppStorage.setOrCreate(Constants.SAFE_TOP_HEIGHT_KEY, px2vp(topArea.topRect.height))

        // 获取底部导航区域的高度，并转换为虚拟像素单位存储
        const bottomArea =  windowObject.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        AppStorage.setOrCreate(Constants.SAFE_BOTTOM_HEIGHT_KEY, px2vp(bottomArea.bottomRect.height))
      }
    } catch (error) {
      Logger.error('开启窗口全屏模式', JSON.stringify(error))
    }
  }

  async exitFullScreen() {
    try {
      if (this.mContext) {
        // 获取当前应用的主窗口对象
        const windowObject = await window.getLastWindow(this.mContext)
        // 设置窗口为非全屏模式
        await windowObject.setWindowLayoutFullScreen(false)

        // 重置状态栏高度为0
        AppStorage.setOrCreate(Constants.SAFE_TOP_HEIGHT_KEY, 0)
        AppStorage.setOrCreate(Constants.SAFE_BOTTOM_HEIGHT_KEY, 0)
      }
    } catch (error) {
      Logger.error('关闭窗口全屏模式', JSON.stringify(error))
    }
  }
}