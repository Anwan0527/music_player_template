import { PlayStateType } from '../models/playState'

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

        Image($r('app.media.ic_paused'))
          .fillColor('#4cafc6')
          .width(20)

        Image($r('app.media.ic_next'))
          .width(20)
          .aspectRatio(1)
          .fillColor('#4cafc6')

      }.height('100%')
    }
    .width('100%')
    .height(60)
    .backgroundColor('#ff1c1c21')
    .justifyContent(FlexAlign.SpaceBetween)

  }
}

export default PlayerNav