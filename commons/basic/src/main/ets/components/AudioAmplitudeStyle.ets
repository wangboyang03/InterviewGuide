@Component
export struct AudioAmplitudeStyle {
  @Prop @Watch('onChangeAmplitude') maxAmplitude: number = 0
  @State amplitude: number = 0

  onChangeAmplitude() {
    if (this.maxAmplitude < 300) {
      this.amplitude = 0
    } else if (this.maxAmplitude > 30000) {
      this.amplitude = 1
    } else {
      this.amplitude = this.maxAmplitude / 30000
    }
  }
  build() {
    Row() {
      ForEach(Array.from({length: 40}), (_: number) => {
        Column() {
          Column()
            .backgroundColor($r('app.color.black'))
            .height(this.amplitude * 100 * Math.random())
            .width('100%')
        }
        .backgroundColor('#fffcefef')
        .layoutWeight(1)
        .height(100)
        .justifyContent(FlexAlign.End)
        .margin({ left: 1, right: 1 })
      })
    }
    .height(100) // 统一高度
    .width('100%')
  }
}