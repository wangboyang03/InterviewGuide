export class HMTools {
  private static sInstance: HMTools
  private constructor() {} // 私有构造函数
  public static getInstance(): HMTools {
    if (!HMTools.sInstance) {
      HMTools.sInstance = new HMTools();
    }
    return HMTools.sInstance;
  }

  /**
   * 时间格式化工具
   */
  formatTimerTool(second:number = 0) {
    const day = 24 * 60 * 60
    const hour = 60 * 60
    const minute = 60
    if (second > day) {
      return (second / day).toFixed(1) + '天'
    } else if (second > hour) {
      return (second / hour).toFixed(1) + '小时'
    } else {
      return (second / minute).toFixed(0) + '分钟'
    }
  }
}