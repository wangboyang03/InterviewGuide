import { Constants, NavigationBar } from 'basic'
import { WordItem, Words } from '../models/words'
import { util } from '@kit.ArkTS'
import { application } from '@kit.AbilityKit'
import webview from '@ohos.web.webview'
import { WordDialog } from '../views/WordToastDialog'

@Entry
@Component
struct WordPage {
  @StorageLink(Constants.SAFE_BOTTOM_HEIGHT_KEY) bottomHeight: number = 0
  wordsData: Words = {}
  @State currentType: string = ''
  @State allType: string[] = []
  @State isShowBindSheet: boolean = false
  @State currentCode: string = ''
  controller: webview.WebviewController = new webview.WebviewController() // WebView控制器

  @State currentWordZhCN: string = ''
  @State currentWordEnUS: string = ''
  wordToastDialog = new CustomDialogController({
    builder: WordDialog({
      zh: this.currentWordZhCN,
      en: this.currentWordEnUS
    }),
    customStyle: true
  })

  async getWordsData() {
    try {
      // 1.获取上下文对象 因为rawfile文件在首页模块需要拿到首页的上下文
      const context = this.getUIContext().getHostContext()
      const homepageContext = await application.createModuleContext(context, Constants.HOMEPAGE_MODULE)
      // 2.通过资源管理获取二进制数据
      const uint8Array = homepageContext.resourceManager.getRawFileContentSync('word.json')
      // 3.解析数据
      const textDecoder = new util.TextDecoder()
      const jsonString = textDecoder.decodeToString(uint8Array)
      this.wordsData = JSON.parse(jsonString)
      this.allType = Object.keys(this.wordsData)
      if (this.allType.length > 0) {
        this.currentType = this.allType[0]
      }

    } catch (error) {
      // 日志.
    }
  }

  aboutToAppear(): void {
    this.getWordsData()
  }

  build() {
    Column() {
      NavigationBar({ title: '常用单词', showRightIcon: false })
      Row() {
        Column({ space: 4 }) {
          Text('开发常用词汇')
          Text(`共${this.wordsData[this.currentType]?.length ?? 0}个单词`)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_03'))
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.currentType)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_01'))
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
        }
        .bindMenu(this.getMenuBuilder) // 绑定半模态
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .border({ width: { top: 0.5 }, color: $r('app.color.common_gray_bg') })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))

      List() {
        ForEach(this.wordsData[this.currentType], (item: WordItem) => {
          ListItem() {
            Row({ space: 6 }) {
              // 小喇叭
              Image($r('sys.media.ohos_ic_public_sound'))
                .width(20)
                .aspectRatio(1)
                .alignSelf(ItemAlign.Start)
                .fillColor($r('app.color.common_gray_03'))
                .onClick(() => {
                  this.currentWordZhCN = item.zh
                  this.currentWordEnUS = item.en
                  this.wordToastDialog.open()
                })
              Column({ space: 10 }) {
                Text(item.en)
                  .fontWeight(FontWeight.Bold)
                Text(item.zh)
                  .fontSize(14)
                  .fontColor($r('app.color.common_gray_03'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Row() {
                Text('详细代码')
                  .fontSize(12)
                  .fontColor($r('app.color.common_gray_01'))
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(16)
                  .aspectRatio(1)
                  .fillColor($r('app.color.common_gray_01'))
              }
              .alignSelf(ItemAlign.End)
              .onClick(() => {
                this.currentCode = item.code
                if (!!this.currentCode) {
                  this.isShowBindSheet = true
                }
              })
            }
            .padding(16)
          }
        })
      }
      .width('100%')
      .height('100%')
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_bg')
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.isShowBindSheet, this.getCodeBuilder(), {
      detents: [SheetSize.FIT_CONTENT],
      title: {title: '示例代码'}
    })
    .padding({
      bottom: this.bottomHeight
    })
  }

  @Builder getMenuBuilder() {
    Menu() {
      ForEach(this.allType, (item: string) => {
        MenuItem({ content: item })
          .constraintSize({
            minWidth: 100
          })
          .onClick(() => {
            this.currentType = item
          })
      })
    }
  }

  @Builder getCodeBuilder() {
    Column() {
      Web({
        src: $rawfile("word.html"),
        controller: this.controller
      })
        .width("100%")
        .height(300)
        .onPageEnd(() => this.currentCode && this.controller.runJavaScript(`writeHtml(\`${this.currentCode}\`)`))
    }
    .padding(20)
    .justifyContent(FlexAlign.Center)
  }
}