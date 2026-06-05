import { Constants, PAGE_PATH } from "../Constants";
import { ClockInResponse } from "../models/user";
import { Auth } from "./Auth";
import { NetworkUtil } from "./NetworkUtil";
import router from "@ohos.router";
import { promptAction } from "@kit.ArkUI";

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

  async getClockInNumber() {
    // 1.获取用户信息
    const user = Auth.getInstance().getUser()
    // 2.判断用户是否登录
    if (!!user?.token) {
      // 3.今天没有打卡 就去打卡 然后到登录页
      if (user.clockinNumbers == 0) {
        const result = await NetworkUtil.getInstance().request<ClockInResponse>({
          url: Constants.CLOCKIN,
          method: 'post'
        })
        user.clockinNumbers = result.clockinNumbers
        Auth.getInstance().setUser(user)
        promptAction.openToast({message: `${user.nickName ?? user.username},打卡成功,已连续打卡${user.clockinNumbers}天`})
      }
      promptAction.openToast({message: `${user.nickName ?? user.username},今日已打卡,已连续打卡${user.clockinNumbers}天`})
      router.pushUrl({
        url: PAGE_PATH.CLOCK_IN_PAGE
      })
    } else {
      router.pushUrl({
        url: PAGE_PATH.LOGIN_PAGE
      })
    }
  }
}