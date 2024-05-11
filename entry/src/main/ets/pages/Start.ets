import router from '@ohos.router'

@Entry
@Component
struct Advertisement {
  @State time: number = 5
  timer: number = -1
  aboutToAppear() {
    // 必须重置才能改动画的内容
    this.timer = setInterval(() => {
      if (this.time <= 0) {
        clearInterval(this.timer)
        router.replaceUrl({
          url: 'pages/Index'
        })
        return
      }
      this.time -= 1
    }, 1000)
  }

  aboutToDisappear() {
    clearInterval(this.timer)
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row() {
      }
      .width('100%')
      .height('100%')
      .backgroundImage($r('app.media.ad'))
      .backgroundImageSize({
        width: '100%',
        height: '100%'
      })
      Button(`跳过${this.time}`)
        .onClick(() => {
          router.replaceUrl({
            url: 'pages/Index'
          })
        })
        .margin(12)
        .backgroundColor('#ccc')
        .fontColor('#fff')
    }
    .width('100%')
    .height('100%')
  }
}