const localStorage = new LocalStorage()
interface songItemType {
  img: string
  name: string
  author: string
  url: string
  id: string
}

interface PlayStateType {
  img: string
  name: string
  author: string
  url: string
  playIndex: number
  time: number
  duration: number
  isPlay: boolean
  playMode: 'auto' | 'repeat' | 'random'
  playList: songItemType[]
}
class PlayStateTypeModel implements PlayStateType {
  img: string = ''
  name: string = ''
  author: string = ''
  url: string = ''
  playIndex: number = 0
  time: number = 0
  duration: number = 0
  isPlay: boolean = false
  playMode: 'auto' | 'repeat' | 'random' = 'auto'
  playList: songItemType[] = []

  constructor(model: PlayStateType) {
    this.img = model.img
    this.name = model.name
    this.author = model.author
    this.url = model.url
    this.playIndex = model.playIndex
    this.time = model.time
    this.duration = model.duration
    this.isPlay = model.isPlay
    this.playMode = model.playMode
    this.playList = model.playList
  }
}

const defaultState:PlayStateType  = new PlayStateTypeModel({
  img: '',
  name: '',
  author: '',
  url: '',
  playIndex: 0,
  time: 0,
  duration: 0,
  isPlay: false,
  playMode: 'auto',
  playList: []
} as PlayStateType)
@Entry(localStorage)
@Component
struct WidgetCard {
  @State
  randomColor: string = 'rgb(0,0,0)'
  @LocalStorageProp('playState')
  @Watch('updateState')
  playState:PlayStateType = defaultState
  updateState(){
    this.randomColor = `rgb(${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)})`
  }
  // 图片
  @LocalStorageProp('fileName')
  fileName: string = ''
  build() {
    Row() {
      Column() {
        Row() {
          Row() {
            Image('memory://'+this.fileName)
              .width('60%')
              .borderRadius(400)
          }
          .shadow({
            radius: 30,
            color: this.randomColor
          })
          .animation({
            duration: 1000,
            onFinish:()=>{
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
            y:10
          })
          .onClick(()=>{
              postCardAction(this,{
                action:'router',
                abilityName:'EntryAbility'
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
            .onClick(()=>{
              //无法导入AVPlayerClass
              // 通知应用切换下一首
              // 没有办法在页面使用发布类，但是Ability可以发布
              postCardAction(this,{
                'action':'message',
                'params':{
                  'type':'prev'
                }
              })
            })
          // 下一首
          Image($r('app.media.ic_next'))
            .fillColor(Color.White)
            .width(30)
            .onClick(()=>{
              //无法导入AVPlayerClass
              // 通知应用切换下一首
              // 没有办法在页面使用发布类，但是Ability可以发布
              postCardAction(this,{
                'action':'message',
                'params':{
                  'type':'next'
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
    .backgroundImage('memory://'+this.fileName)
    .backgroundImageSize(ImageSize.Cover)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
    .backgroundColor('#ec5c87')

  }
}