import { webview } from '@kit.ArkWeb';
import { NavigationBar } from 'basic';
import { WebViewResponse } from '../models';

@Entry
@Component
struct WebPage {
  @State title: string = 'Hello World'; // 标题
  @State src: string = ''; // 网页地址
  controller = new webview.WebviewController()

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as WebViewResponse
    this.title = params.title
    this.src = params.src
  }

  build() {
    Column() {
      NavigationBar({
        title: this.title
      })
      Web({
        src: this.src,
        controller: this.controller
      })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}