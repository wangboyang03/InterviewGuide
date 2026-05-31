import { window } from "@kit.ArkUI";
import { Logger } from "../../../../Index";

export class StatusManager {
  private static sInstance: StatusManager;
  mUIContext?: UIContext

  private constructor() {
  } // 私有构造函数

  public static getInstance(): StatusManager {
    if (!StatusManager.sInstance) {
      StatusManager.sInstance = new StatusManager();
    }
    return StatusManager.sInstance;
  }

  init(mContext:UIContext) {
    this.mUIContext = mContext
    return this;
  }

  // 设置状态栏
  private async setBar(config: window.SystemBarProperties) {
    try {
      if (this.mUIContext) {
        // 获取当前窗口
        const windowObject = await window.getLastWindow(this.mUIContext.getHostContext()!)
        // 设置窗口的系统栏属性
        await windowObject.setWindowSystemBarProperties(config)
      }
    } catch (error) {
      Logger.error('设置系统状态栏', JSON.stringify(error))
    }
  }

  // 图标深色模式 白天模式
  async setDarkBar() {
    await this.setBar({ statusBarContentColor: '#000000' })
  }

  // 图标浅色模式 暗夜模式
  async setLightBar() {
    await this.setBar({ statusBarContentColor: '#FFFFFF' })
  }
}