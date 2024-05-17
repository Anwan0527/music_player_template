interface songItemType {
  img: string
  name: string
  author: string
  url: string
  id: string
}

export class PlayStateType {
  img: string = "" // 音乐封面
  name: string = "" // 音乐名称
  author: string = "" // 作者
  url: string = "" // 当前播放连接
  playIndex: number = 0 // 当前在播放列表中的播放索引
  time: number = 0 // 播放时间
  duration: number = 0 // 音乐的播放市场
  isPlay: boolean = false // 是否正在播放
  playMode: 'auto' | 'repeat' | 'random' = "auto" // 播放模式
  playList: songItemType[] = [] // 当前的播放列表
}

const localStorage = new LocalStorage()
@Entry(localStorage)
@Component
struct WidgetCard {
  @State
  randomColor: string = 'rgb(0,0,0)'
  @LocalStorageProp('song')
  @Watch('updateState')
  playState: PlayStateType = new PlayStateType()

  @LocalStorageProp('formId')
  @Watch("updateFormId")
  formId: string = ""

  updateFormId () {
    console.log("formId_card", this.formId)
    postCardAction(this, {
      action: 'call',
      abilityName: 'EntryAbility',
      params: {
        method: 'getFormId',
        formId: this.formId
      }
    })
  }
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
              //无法导入AVPlayerClass
              // 通知应用切换下一首
              postCardAction(this, {
                action: 'call',
                abilityName: 'EntryAbility',
                params: {
                  method: 'prev'
                }
              })
            })
          Text(this.playState.name || "测试")
            .fontColor(Color.White)
          // 下一首
          Image($r('app.media.ic_next'))
            .fillColor(Color.White)
            .width(30)
            .onClick(() => {
              //无法导入AVPlayerClass
              // 通知应用切换下一首
              // 没有办法在页面使用发布类，但是Ability可以发布
              postCardAction(this, {
                action: 'call',
                abilityName: 'EntryAbility',
                params: {
                  method: 'next'
                }
              })
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