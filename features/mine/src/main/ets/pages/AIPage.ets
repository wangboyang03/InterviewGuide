import { Constants, Logger, NavigationBar } from 'basic';
import { util } from '@kit.ArkTS';
import { application } from '@kit.AbilityKit';
import { Message } from '../models';
import { fetchEventSource } from 'fetch_event_source';
import { http } from '@kit.NetworkKit';
import { Response } from '../models/ai';
import { KeyboardAvoidMode } from '@kit.ArkUI';

@Entry
@Component
struct AIPage {
  @StorageProp(Constants.SAFE_BOTTOM_HEIGHT_KEY) bottomHeight: number = 0
  api_url: string = ''
  api_key: string = ''
  @State inputText: string = ''
  @State messages: Message[] = []
  roleCollection: Message[] = [
    { "role": "system", "content": "你是虚拟女友,你的名字叫小羊大王,需要你陪伴主人而且主人不开心的时候哄主人,温柔可爱是你最大的特点" },
    { "role": "user", "content": this.inputText ?? 'hello' }
  ]
  listScroller: Scroller = new Scroller()


  /**
   * 获取资源目录JSON文件内容
   * @param file rawfile目录下的文件
   */
  async getRawFileJSONString(file: string) {
    const context = AppStorage.get<Context>(Constants.GLOBAL_CONTEXT)
    const mineContext = await application.createModuleContext(context, Constants.MINE_MODULE)
    if (mineContext) {
      const uint8Array = mineContext.resourceManager.getRawFileContentSync(file)
      const textDecoder = new util.TextDecoder()
      const jsonString = textDecoder.decodeToString(uint8Array)
      const config = JSON.parse(jsonString) as Record<string, string>
      this.api_url = config.api_url
      this.api_key = config.api_key
    }
  }

  /**
   * 获取SSE流并解析
   */
  fetchSSEStreamAndParse() {
    try {
    fetchEventSource(this.api_url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.api_key}`
        },
        extraData: {
          "model": "DeepSeek-V3", // 调用的模型
          "max_tokens": 1024, // 生成的最大token数
          "messages": this.buildApiMessages(), // 角色信息配置
          "stream": true, // 是否流式返回
          "stream_options": {
            "include_usage": true // 是否返回Usage信息
          },
          "temperature": 1.0 // 控制采样随机性的浮点数，值较低时模型更具确定性，值较高时模型更具创造性。"0"表示贪婪取样。默认为1.0。
        },
        onopen: async () => {
          this.messages.push({ role: 'assistant', content: '' })
        },
        onmessage: (data) => {
            try {
            const res = JSON.parse(data.data) as Response
            const newContent = res.choices[0]?.delta?.content ?? '' // 最新请求到的内容
            const oldContent = this.messages[this.messages.length-1] // 拿到上一条数据
            this.messages.splice(this.messages.length -1, 1, {
              role: 'assistant',
              content: oldContent.content + newContent
            })
            this.listScroller.scrollEdge(Edge.Bottom)
            // Logger.info(this.messages)
          } catch (error) {
          }
        },
        onclose: () => {

        },
        onerror: (error) => {
          Logger.error(error)
          return undefined
        }
      },
    )} catch (error) {
      Logger.error(error)
      // 日志。
    }

  }

  /**
   * 发送消息
   */
  sendMessage() {
    if (!!this.inputText.trim()) {
      const userText = this.inputText.trim()
      this.messages.push({ role: 'user', content: userText })
      this.roleCollection.push({ role: 'user', content: userText })
      this.inputText = ''
      this.listScroller.scrollEdge(Edge.Bottom)
      this.fetchSSEStreamAndParse()
    }
  }

  buildApiMessages(): Message[] {
    const systemMsg: Message = {
      role: 'system',
      content: '你是一个鸿蒙面试助手, 请简洁明了回答问题, 不要长篇大论, 直击重点，也可回答任何非鸿蒙面试问题，但请遵守中国大陆法律法规'
    }
    const history = this.messages.filter(m => m.role !== 'system')
    if (history.length == 0) {
      history.push({ role: 'user', content: '你好' })
    }
    return [systemMsg, ...history]
  }

  async aboutToAppear(): Promise<void> {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE) // 实现键盘避让
    await this.getRawFileJSONString('config.json')
    this.fetchSSEStreamAndParse()
  }

  build() {
    Column() {
      NavigationBar({
        title: '面通AI主页面',
        showRightIcon: false
      })

      Column() {
        List({scroller: this.listScroller}) {
          ForEach(this.messages, (item: Message) => {
            ListItem() {
              Column() {
                if (item.role == 'user') {
                  this.userMessage(item)
                } else if (item.content) {
                  this.assistantMessage(item)
                }
              }
              .alignItems(HorizontalAlign.Start)
              .constraintSize({ maxWidth: '85%' })
              .padding({ left: 16, right: 40 })
            }
          })
        }
        .width('100%')
        .height('100%')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // 底部输入区域
      Row() {
        TextInput({ text: $$this.inputText, placeholder: '请输入消息...' })
          .placeholderColor('#999999')
          .placeholderFont({ size: 15 })
          .fontSize(15)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .height(40)
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
          .onSubmit(() => this.sendMessage())

        Button('发送')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(this.inputText.trim() ? '#07C160' : '#C0C0C0')
          .borderRadius(20)
          .height(40)
          .padding({ left: 18, right: 18 })
          .margin({ left: 10 })
          .enabled(!!this.inputText.trim())
          .onClick(() => this.sendMessage())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: this.bottomHeight })
      .backgroundColor('#F7F7F7')
      .border({
        width: { top: 0.5 },
        color: '#E0E0E0'
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder userMessage(item: Message) {
    Row() {
      Blank()
      Column() {
        Text(item.content)
          .fontSize(16)
          .fontColor('#1A1A1A')
          .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      }
      .constraintSize({ maxWidth: '70%' })
      .backgroundColor('#95EC69')
      .borderRadius({
        topLeft: 18,
        topRight: 18,
        bottomLeft: 18,
        bottomRight: 4
      })
      .shadow({
        radius: 4,
        color: '#10000000',
        offsetX: 0,
        offsetY: 1
      })
    }
    .width('100%')
    .padding({ left: 40, right: 16 })
  }

  @Builder assistantMessage(item: Message) {
    Text(item.content)
      .fontSize(16)
      .fontColor('#333333')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor('#FFFFFF')
      .borderRadius({
        topLeft: 18,
        topRight: 18,
        bottomLeft: 4,
        bottomRight: 18
      })
      .shadow({
        radius: 4,
        color: '#10000000',
        offsetX: 0,
        offsetY: 1
      })
  }
}