export class BasicTool {
  private static sInstance: BasicTool;
  private constructor() {}

  public static getInstance(): BasicTool {
    if (!BasicTool.sInstance) {
      BasicTool.sInstance = new BasicTool();
    }
    return BasicTool.sInstance;
  }

  formatTimeFromSeconds(second: number = 0) {
    const day = 60 * 60 * 24
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