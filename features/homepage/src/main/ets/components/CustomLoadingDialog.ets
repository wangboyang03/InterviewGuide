@CustomDialog
export struct CustomLoadingDialog {
  controller: CustomDialogController
  @Prop label: string = '加载中...'

  build() {
    Column() {
      Column({ space: 10 }) {
        // 内置加载动画组件
        LoadingProgress()
          .width(48)
          .height(48)
          .color($r('app.color.white'))

        // 提示文本
        if (this.label) {
          Text(this.label)
            .fontSize(14)
            .fontColor($r('app.color.white'))
        }
      }
      .justifyContent(FlexAlign.Center)
      .width(120)
      .height(120)
      .backgroundColor('rgba(0,0,0,0.6)')
      .borderRadius(16)
    }
  }
}