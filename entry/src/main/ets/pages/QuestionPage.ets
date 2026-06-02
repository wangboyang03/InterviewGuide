import { HMNavigationBar, HMTag } from '../commons/components'
import { GlobalVariable } from '../commons/constants'
import { QuestionDetail, QuestionOptionParams, QuestionPageParams } from '../models'
import { hmHttp } from '../commons/utils/HMHttp'
import { webview } from '@kit.ArkWeb'
import { HMCustomDialog } from '../commons/components/HMCustomDialog'
import { JSON } from '@kit.ArkTS'

@Entry
@Component
struct QuestionPage {
  @StorageProp(GlobalVariable.SAFE_BOTTOM_HEIGHT) bottomHeight: number = 0
  @State item: QuestionDetail = {} as QuestionDetail
  controller = new webview.WebviewController()
  dialog = new CustomDialogController({
    builder: HMCustomDialog({
      label: '拼命加载中...'
    }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  async aboutToAppear(): Promise<void> {
    const params = this.getUIContext().getRouter().getParams() as QuestionPageParams
    if (params) {
      // this.getUIContext().getPromptAction().showDialog({
      //   message: JSON.stringify(params.item)
      // })
      this.item = params.item as QuestionDetail
      this.item = await this.getQuestionDetail(params.item.id)
      if (this.item.answer) {
        this.controller.loadUrl($rawfile('question.html')) // 重新加载网页
      }
    }
  }

  onPageHide(): void {
    this.dialog.close()
  }

  async getQuestionDetail(id: string) {
    this.dialog.open()
    const result = await hmHttp.request<QuestionDetail>({
      url: `question/${id}`
    })
    this.dialog.close()
    return result
  }

  /**
   * 收藏、取消收藏 点赞、取消点赞
   */
  async getQuestionOption(optType: 1 | 2, click: 0 | 1) {
    // 获取操作类型
    const params: QuestionOptionParams = {
      id: this.item.id,
      type: 0,
      optType
    }

    try {
      // 请求接口
      hmHttp.request<null, QuestionOptionParams>({
        url: click == 1 ? 'question/opt' : 'question/unOpt',
        method: 'POST',
        params
      })
      // this.getUIContext().getPromptAction().showToast({
      //   message: JSON.stringify(result)
      // })
      // 操作本地数据
      if (optType == 1) {
        this.item.likeFlag = click
        this.getUIContext().getPromptAction().showToast({message: click ? '点赞成功' : '取消点赞'})
      } else if (optType == 2) {
        this.item.collectFlag = click
        this.getUIContext().getPromptAction().showToast({message: click ? '收藏成功' : '取消收藏'})
      }
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({message: error.message})
    }
  }

  build() {
    Column() {
      HMNavigationBar({ title: '试题详情', showRightIcon: false })
      // 题目
      this.TitleBuilder('题目：')
      Text(this.item.stem ?? '')
        .width('100%')
        .padding(16)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 12 }) {
        ForEach(this.item.stage, ((item: string)=>{
          HMTag({ text: item, color: '#ff6600' })
        }))
        Blank()
        Image($r("app.media.ic_home_more"))
          .width(20)
          .aspectRatio(1)
          .bindMenu(this.MenuBuilder())
      }
      .width('100%')
      .padding({ bottom: 16, left: 16, right: 16 })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))
      // 内容
      this.TitleBuilder('答案：')
      Web({
        src: $rawfile('question.html'),
        controller: this.controller
      }).width('100%').layoutWeight(1).onPageEnd(()=>{
        this.controller.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
      })

      Row({ space: 80 }) {
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
          Text(' 上一题')
            .fontColor($r('app.color.common_gray_01'))
        }

        Row() {
          Text('下一题 ')
            .fontColor($r('app.color.common_gray_03'))
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_03'))
        }
      }
      .height(44)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.bottomHeight })
  }

  @Builder
  TitleBuilder(text: string) {
    Row() {
      Text()
        .width(2)
        .height(12)
        .backgroundColor($r('app.color.black'))
        .margin({ right: 13 })
      Text(text)
        .fontWeight(700)
    }
    .width('100%')
    .padding({ top: 10 })
    .height(32)
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: this.item.likeFlag == 1 ? '取消点赞' : '点赞' })
        .onClick(()=>this.getQuestionOption(1, this.item.likeFlag == 1 ? 0 : 1))
      MenuItem({ content: this.item.collectFlag == 1 ? '取消收藏' : '收藏' })
        .onClick(()=>this.getQuestionOption(2, this.item.collectFlag == 1 ? 0 : 1))
      MenuItem({ content: '点我反馈' })
      MenuItem({ content: '试题分享' })
    }
    .width(108)
  }
}