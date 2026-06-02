import { CategoryTag, Constants, NavigationBar, NetworkUtil } from 'basic'
import { QuestionDetail, QuestionPageResponse } from '../models/question'
import { webview } from '@kit.ArkWeb'
import { CustomLoadingDialog } from '../components/CustomLoadingDialog'

@Entry
@Component
struct QuestionPage {
  @StorageProp(Constants.SAFE_BOTTOM_HEIGHT_KEY) bottomHeight: number = 0
  @State currentItem: QuestionDetail = {} as QuestionDetail
  controller: WebviewController = new webview.WebviewController()
  loadingDialog = new CustomDialogController({
    builder: CustomLoadingDialog(),
    customStyle: true, // 打开自定义样式
    alignment: DialogAlignment.Center // 居中显示
  })

  /**
   * 获取当前试题详情数据
   * @param id 试题id
   */
  async getCurrentQuestionData(id: string) {
    this.loadingDialog.open()
    const result = await NetworkUtil.getInstance().request<QuestionDetail>({
      url: `${Constants.QUESTION_DETAIL}${id}`
    })
    this.loadingDialog.close()
    return result;
  }

  async aboutToAppear(): Promise<void> {
    const params = this.getUIContext().getRouter().getParams() as QuestionPageResponse
    if (!!params) {
      // this.getUIContext().getPromptAction().showToast({message:JSON.stringify(params)})
      this.currentItem = params.item as QuestionDetail
      this.currentItem = await this.getCurrentQuestionData(params.item.id)
      this.controller.loadUrl($rawfile('question.html')) // 每次页面创建都加载一下网页渲染当前答案
    }
  }

  build() {
    Column() {
      NavigationBar({
        title: '题目详情',
        showRightIcon: true,
        rightIcon: $r('app.media.ic_shareIcon')
      })
      this.TitleBuilder('题目: ')
      Text(this.currentItem.stem ?? '')
        .width('100%')
        .padding(16)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 12 }) {
        // CategoryTag({ tag: 'HarmonyOS' })
        // CategoryTag({ tag: 'ArkTS', tagColor: '#ff6600' })
        ForEach(this.currentItem.stage, (tag: string) => {
          CategoryTag({ tag: tag, tagColor: '#ff6600' })
        })
        CategoryTag({ difficulty: this.currentItem.difficulty })
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
      /*Text(this.currentItem.answer ?? '暂无答案')
        .layoutWeight(1)
        .padding(16)*/
      Web({
        src: $rawfile('question.html'),
        controller: this.controller
      })
        .width('100%')
        .layoutWeight(1)
        .onPageEnd(() => {
          if (this.currentItem.answer) {
            this.controller.runJavaScript(`writeHtml(\`${this.currentItem.answer}\`)`)
          }
        })

      Row({ space: 80 }) {
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
          Text(' ' + '上一题')
            .fontColor($r('app.color.common_gray_01'))
        }

        Row() {
          Text('下一题' + ' ')
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

  /**
   * 题目组件
   * @param text 题目文本
   */
  @Builder TitleBuilder(text: string) {
    Row() {
      Text()
        .width(2)
        .height(12)
        .linearGradient({
          angle: 143,
          colors: [
            ['#83D8B2', 0.0133],
            ['#41B883', 0.9867]
          ]
        })
        .margin({ right: 13 })
      Text(text).fontWeight(700)
    }
    .width('100%')
    .padding({ top: 10 })
    .height(32)
  }

  /**
   * 菜单组件
   */
  @Builder MenuBuilder() {
    Menu() {
      MenuItem({ content: '点赞' })
      MenuItem({ content: '收藏' })
      MenuItem({ content: '点我反馈' })
      MenuItem({ content: '试题分享' })
    }
    .width(108)
  }
}