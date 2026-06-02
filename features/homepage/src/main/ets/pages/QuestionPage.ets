import { CategoryTag, Constants, NavigationBar, NetworkUtil, Logger } from 'basic'
import { QuestionDetail, QuestionOptionResponse, QuestionPageResponse } from '../models/question'
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

  /**
   * 操作当前试题 点赞或取消点赞、收藏或取消收藏
   * @param optType 1点赞 2收藏
   * @param option 0取消 1确认
   */
  OptionCurrentQuestion(optType: 1 | 2, option: 0 | 1) {
    // 1.分析数据类型 准备参数
    const params = {
      id: this.currentItem.id,
      optType: optType,
      type: 0 // 默认面试题
    } as QuestionOptionResponse
    try {
      // 2.发送网络请求
      NetworkUtil.getInstance().request<null, QuestionOptionResponse>({
        // 需要通过传入参数来判断当前是什么操作
        url: option == 1 ? Constants.OPTION_MENU : Constants.UN_OPTION_MENU,
        method: 'post',
        data: params
      })

      // 3.处理本地操作
      if (optType == 1) {
        this.currentItem.likeFlag = option // 执行点赞操作
        this.getUIContext().getPromptAction().showToast({message: option ? '点赞成功' : '取消点赞'})
      } else if (optType == 2) {
        this.currentItem.collectFlag = option // 执行收藏操作
        this.getUIContext().getPromptAction().showToast({message: option ? '收藏成功' : '取消收藏'})
      }
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({message:'操作失败'})
      Logger.error('OptionCurrentQuestion操作失败', error)
    }
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

  onPageHide(): void {
    this.loadingDialog.close()
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
      MenuItem({ content: this.currentItem.likeFlag == 1 ? '取消点赞' : '点赞' }).onClick(() => this.OptionCurrentQuestion(1, this.currentItem.likeFlag == 1 ? 0 : 1))
      MenuItem({ content: this.currentItem.collectFlag == 1 ? '取消收藏' : '收藏' }).onClick(() => this.OptionCurrentQuestion(2, this.currentItem.collectFlag == 1 ? 0 : 1))
      MenuItem({ content: '点我反馈' })
      MenuItem({ content: '试题分享' })
    }
    .width(108)
  }
}