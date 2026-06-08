@CustomDialog
export struct InputFileNameDialog {
  controller: CustomDialogController
  @Prop name: string = '' // 接收输入框内容
  onSubmit: (name: string) => void = () => {} // 执行确认回调

  build() {
    Column({ space: 12 }) {
      Text('修改名字：')
        .height(40)
        .fontWeight(500)
      TextInput({ text: $$this.name })
      Row({ space: 120 }) {
        Text('取消')
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_02'))
          .onClick(() => {
            this.controller.close()
          })
        Text('确认')
          .fontWeight(500)
          .fontColor($r('app.color.common_blue'))
          .onClick(() => {
            this.onSubmit(this.name)
          })
      }
      .height(40)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(12)
    .width('80%')
    .backgroundColor($r('app.color.white'))
  }
}