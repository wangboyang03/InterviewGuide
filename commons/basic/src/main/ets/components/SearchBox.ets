import { Auth, Logger, NetworkUtil } from "../utils"
import { scanBarcode } from "@kit.ScanKit"
import { Constants, PAGE_PATH } from "../Constants"
import { QuestionDetail, QuestionPageResponse } from "../models"

@Component
export struct SearchBox {
  @Prop boxHeight: number = 32
  @Prop searchText: string = "搜索题目"
  @BuilderParam rightBuilder: () => void = this.defaultBuilder //插槽

  /**
   * 扫码看题
   */
  async scanQuestionCode() {
    try {
      const context = this.getUIContext().getHostContext()
      if (!!context) {
        if (canIUse("SystemCapability.Multimedia.Scan.ScanBarcode")) {
          const result = await scanBarcode.startScanForResult(context)
          if (!!result.originalValue) {
            // 先发请求拿到题目详情信息
            const currentItem = await NetworkUtil.getInstance().request<QuestionDetail>({
              url: `${Constants.QUESTION_DETAIL}${result.originalValue}`
            })
            Auth.getInstance().checkAuth({
              url: `${PAGE_PATH.QUESTION_PAGE}`,
              params: {
                item: currentItem,
                list: [currentItem]
              } as QuestionPageResponse
            })
          }
        } else {
          this.getUIContext().getPromptAction().showToast({message: "当前设备不支持扫码"})
        }
      }
    } catch (error) {
      Logger.error("scanQuestionCode", error)
      this.getUIContext().getPromptAction().showToast({message: "扫码失败"})
    }
  }

  build() {
    Row({ space: 20 }) {
      Image($r("app.media.ic_home_scan")) // 扫一扫
        .width(24)
        .aspectRatio(1)
        .onClick(() => Auth.getInstance().checkAuth((): Promise<void> => this.scanQuestionCode()))
      Row() {
        Image($r("app.media.ic_common_search"))
          .width(14)
          .aspectRatio(1)
          .fillColor($r("app.color.common_gray_01"))
        Text(this.searchText)
          .fontSize(14)
          .fontColor($r("app.color.common_gray_01"))
      }
      .layoutWeight(1)
      .height(this.boxHeight)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r("app.color.common_gray_bg"))
      .borderRadius(16)
      .onClick(() => {
        Auth.getInstance().checkAuth({
          url: `${PAGE_PATH.SEARCH_PAGE}`
        })
      })

      this.rightBuilder()
    }
    .padding({
      left: 16,
      right: 16
    })
    .width("100%")
    .height(64)
  }

  @Builder defaultBuilder() {}
}