import { Logger } from "../../../../Index";
import { Constants } from "../Constants";
import { TrackingRequest } from "../models/common";
import { NetworkUtil } from "./NetworkUtil";
import preferences from "@ohos.data.preferences";

export class TrackingPointUtil {
  private static sInstance: TrackingPointUtil;
  // private recordList: TrackingRequest[] = []
  private trackingStorage?: preferences.Preferences

  private constructor() {}

  public static getInstance(): TrackingPointUtil {
    if (TrackingPointUtil.sInstance == null) {
      TrackingPointUtil.sInstance = new TrackingPointUtil();
    }
    return TrackingPointUtil.sInstance;
  }

  /**
   * 获取首选项实例
   */
  getStorage() {
    if (!this.trackingStorage) {
      const context = AppStorage.get<Context>(Constants.GLOBAL_CONTEXT)
      this.trackingStorage = preferences.getPreferencesSync(context, {name: Constants.TRACKING_STORAGE_KEY})
    }
    return this.trackingStorage
  }

  /**
   * 记录学习时长埋点
   * @param startTime 开始学习时间
   * @param endTime 结束学习时间
   * @param questionId 题目id
   */
  record(startTime: number, endTime: number, questionId: string) {
    try {
      // 1.读取埋点记录信息
      const trackingMessage = this.getStorage().getSync(Constants.TRACKING_LEARN_KEY, '[]')
      const recordList = JSON.parse(trackingMessage as string) as TrackingRequest[]
      // 2.添加数据
      recordList.push({startTime, endTime, questionId})
      this.getStorage().putSync(Constants.TRACKING_LEARN_KEY, JSON.stringify(recordList))
      this.getStorage().flushSync() // 写入磁盘
    } catch (error) {
      Logger.error(error)
    }
  }

  /**
   * 上报学习时长埋点
   * @param force 是否强制上报
   */
  async report(force: boolean = false) {
    try {
      // 1.读取埋点记录信息
      const trackingMessage = this.getStorage().getSync(Constants.TRACKING_LEARN_KEY, [])
      const recordList = JSON.parse(trackingMessage as string) as TrackingRequest[]
      // 2.判断埋点数量 符合数量进行上报
      if (recordList.length >= 5 || !!(recordList.length && force)) {
        await NetworkUtil.getInstance().request<null>({
          url: Constants.TRACKING_TIME,
          method: 'post',
          data: {
            timeList: recordList
          }
        })
        // 上报完毕 清除首选项内容
        this.getStorage().deleteSync(Constants.TRACKING_LEARN_KEY)
        this.getStorage().flushSync() // 写入磁盘
      }
    } catch (error) {
      Logger.error(error)
    }
  }
}