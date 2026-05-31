import window from "@ohos.window";
import { hmLogger } from ".";

class HMStatusBar {
  private ctx: Context | null = null

  init(ctx: Context) {
    this.ctx = ctx
    return this
  }

  /**
   * 通用方法
   */
  private async setBar(config: window.SystemBarProperties) {
    try {
      if (this.ctx) {
        const win = await window.getLastWindow(this.ctx)
        await win.setWindowSystemBarProperties(config)
      }
    } catch (e) {
      hmLogger.info(JSON.stringify(e))
    }
  }

  /**
   * 设置深色
   */
  setDarkBar() {
    this.setBar({ statusBarContentColor: '#000000' })
  }

  /**
   * 设置亮色
   */
  setLightBar() {
    this.setBar({ statusBarContentColor: '#ffffff' })
  }

  /**
   * 设置红色
   */
  setRedBar() {
    this.setBar({ statusBarContentColor: '#ff0000' })
  }

  /**
   * 设置红色背景
   */
  setRedBarBg() {
    this.setBar({ statusBarColor: '#ff0000' })
  }
}

export const hmStatusBar = new HMStatusBar()