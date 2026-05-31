import { window } from "@kit.ArkUI"
import { hmLogger } from "."
import { GlobalVariable } from "../constants"

class HMScreenManager {

  private ctx: Context | null = null

  init(ctx: Context){
   this.ctx = ctx
   return this
  }

  /**
   * 开启全屏模式
   */
 async full(){
    try {
      if(this.ctx){
        // 1. 获取当前窗口
        const win = await window.getLastWindow(this.ctx)
        // 2. 设置全屏模式
        await win.setWindowLayoutFullScreen(true)

        // 3. 全局存储安全区 头部 和 尾部 的高度
        const topArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        AppStorage.setOrCreate(GlobalVariable.SAFE_TOP_HEIGHT, px2vp(topArea.topRect.height))

        const bottomArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        AppStorage.setOrCreate(GlobalVariable.SAFE_BOTTOM_HEIGHT, px2vp(bottomArea.bottomRect.height))
      }
    } catch (e) {
      hmLogger.error(e)
    }
  }

  /**
   * 退出全屏模式
   */
  async exitFull(){
    try {
      if(this.ctx){
        // 1. 获取当前窗口
        const win = await window.getLastWindow(this.ctx)
        // 2. 设置全屏模式
        await win.setWindowLayoutFullScreen(false)

        // 3. 全局存储安全区 头部 和 尾部 的高度
        AppStorage.setOrCreate(GlobalVariable.SAFE_TOP_HEIGHT, 0)
        AppStorage.setOrCreate(GlobalVariable.SAFE_BOTTOM_HEIGHT, 0)
      }
    } catch (e) {
      hmLogger.error(e)
    }
  }
}


export const hmScreenManager = new HMScreenManager()