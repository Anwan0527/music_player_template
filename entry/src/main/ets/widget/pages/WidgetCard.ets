
const localStorage = new LocalStorage()
@Entry(localStorage)
@Component
struct WidgetCard {
  @State
  randomColor: string = 'rgb(0,0,0)'
  updateState() {
    this.randomColor =
      `rgb(${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)})`
  }

  // 图片
  @LocalStorageProp('fileName')
  fileName: string = ''

  build() {
    Row() {
      Column() {
        Row() {
          Row() {
            Image('memory://' + this.fileName)
              .width('60%')
              .borderRadius(400)
          }
          .shadow({
            radius: 30,
            color: this.randomColor
          })
          .animation({
            duration: 1000,
            onFinish: () => {
              this.randomColor = 'rgb(0,0,0)'
            }
          })
          .backgroundImage($r('app.media.ic_cd'))
          .backgroundImageSize(ImageSize.Cover)
          .justifyContent(FlexAlign.Center)
          .width('80%')
          .margin(10)
          .borderRadius(400)
          .aspectRatio(1)
          .translate({
            y: 10
          })
          .onClick(() => {
            postCardAction(this, {
              action: 'router',
              abilityName: 'EntryAbility'
            })
          })
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)


        Row() {
          // 上一首
          Image($r('app.media.ic_prev'))
            .fillColor(Color.White)
            .width(30)
            .onClick(() => {
              // 上一首
            })
          Text("奢香夫人")
            .fontColor(Color.White)
            .fontSize(12)
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            })
            .width("50%")
            .textAlign(TextAlign.Center)

          // 下一首
          Image($r('app.media.ic_next'))
            .fillColor(Color.White)
            .width(30)
            .onClick(() => {
              // 下一首
            })
        }
        .width('100%')
        .height('20%')
        .padding({ left: 10, right: 10 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundImage('memory://' + this.fileName)
    .backgroundImageSize(ImageSize.Cover)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
    .backgroundColor('#ec5c87')

  }
}