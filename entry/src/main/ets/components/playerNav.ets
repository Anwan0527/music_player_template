import { PlayStateType } from '../models/playState'
import AVPlayerClass from '../utils/AVPlayerClass'

@Component
struct PlayerNav {
  @Link
  playState: PlayStateType

  build() {
    Row() {
      Row({ space: 10 }) {
        Image(this.playState.img)
          .width(40)
          .aspectRatio(1)
        Column() {
          Text(this.playState.name)
            .fontColor('#fff')
          Text(this.playState.author)
            .fontSize(12)
            .fontColor('#ccc')
        }.alignItems(HorizontalAlign.Start)
      }.height('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: 16 }) {
        Image($r("app.media.ic_prev"))
          .width(20)
          .aspectRatio(1)
          .fillColor('#4cafc6')
          .onClick(() => {
            AVPlayerClass.playPrevious()
          })
        Image(this.playState.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
          .fillColor('#4cafc6')
          .width(20)
          .onClick(() => {
            this.playState.isPlay ? AVPlayerClass.pause() : AVPlayerClass.singlePlay(this.playState.playList[this.playState.playIndex])
          })

        Image($r('app.media.ic_next'))
          .width(20)
          .aspectRatio(1)
          .fillColor('#4cafc6')
          .onClick(() => {
            AVPlayerClass.playNext()
          })
      }.height('100%')
    }
    .width('100%')
    .height(60)
    .backgroundColor('#ff1c1c21')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 20, right: 20 })
  }
}

export default PlayerNav