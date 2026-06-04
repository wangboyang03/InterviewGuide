import { Logger } from "../../../../Index";
import { Constants } from "../Constants";
import { TrackingRequest } from "../models/common";
import { NetworkUtil } from "./NetworkUtil";

export class TrackingPointUtil {
  private static sInstance: TrackingPointUtil;
  private recordList: TrackingRequest[] = []

  private constructor() {}

  public static getInstance(): TrackingPointUtil {
    if (TrackingPointUtil.sInstance == null) {
      TrackingPointUtil.sInstance = new TrackingPointUtil();
    }
    return TrackingPointUtil.sInstance;
  }

  /**
   * 记录学习时长埋点
   * @param startTime 开始学习时间
   * @param endTime 结束学习时间
   * @param questionId 题目id
   */
  record(startTime: number, endTime: number, questionId: string) {
    this.recordList.push({
      startTime,
      endTime,
      questionId
    })
  }

  /**
   * 上报学习时长埋点
   */
  report() {
    try {
      NetworkUtil.getInstance().request<null>({
        url: Constants.TRACKING_TIME,
        method: 'post',
        data: {
          timeList: this.recordList
        }
      })
      this.recordList = []
    } catch (error) {
      Logger.error(error)
    }
  }
}