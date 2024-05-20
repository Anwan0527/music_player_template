import { AnimatorResult } from '@ohos.animator'
import { songItemType } from '../../models/music'
import {  PlayStateType } from '../../models/playState'
import animator from '@ohos.animator';
import { SONG_KEY } from  '../../constants'
@Entry
@Component
struct Play {
  @State opacityNum: number = 1
  @State panelHeight: string = '0%'
  // 动画需要的数据
  @State randomColor: string = 'rgb(0,0,0)'
  @State randomShakenX: number = 0
  @State randomShakenY: number = 0
  @State rotateAngle: number = 0
  animatorResult: AnimatorResult = animator.create({
    duration: 1000 * 15,
    easing: "linear",
    delay: 0,
    fill: "none",
    direction: "normal",
    iterations: -1,
    begin: 0,
    end: 360
  })

  // // 控制页面按钮是否能点击
  // @State btnEnable: boolean = true
  // 时长数字(ms)转字符串
  number2time(number: number) {
    const ms: number = number % 1000
    const second = (number - ms) / 1000
    const s: number = second % 60
    if (second > 60) {
      const m: number = (second - s) / 60 % 60
      return m.toString()
        .padStart(2, '0') + ':' + s.toString()
        .padStart(2, '0')
    }
    return '00:' + s.toString()
      .padStart(2, '0')
  }

  @Builder
  deleteButton(index: number) {
    Button('删除')
      .backgroundColor($r('app.color.primary_light'))
      .fontColor('#fff')
      .width(80)
      .height('100%')
      .type(ButtonType.Normal)
      .onClick(() => {
         // 删除歌曲
      })

  }

  @StorageLink(SONG_KEY)
  @Watch('changeAnimate')
  playState: PlayStateType = new PlayStateType()

  changeAnimate() {
    if (this.playState.isPlay) {
      // 播放状态
      this.randomColor = `rgb(${Math.floor(Math.random() * 256)},${Math.floor(Math.random() * 256)},${Math.floor(Math.random() * 256)})`
      this.randomShakenX = 2 - Math.random() * 4
      this.randomShakenY = 2 - Math.random() * 4
      this.animatorResult.play()
    } else {
      this.randomColor = 'rbg(0,0,0)'
      this.randomShakenX = 0
      this.randomShakenY = 0
      this.animatorResult.pause()
    }
  }

  async aboutToAppear() {
    // 从首选项加载数据
    if(this.playState.isPlay) {
      this.animatorResult.play()
    }
    this.animatorResult.onframe = (val) => {
      this.rotateAngle = val
    }

  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 播放
      Stack() {
        // 变色背景
        Image(this.playState.img)
          .width('100%')
          .height('100%')
          .blur(1000)
        // 内容
        Column() {
          // //   播放界面
          Column() {
            // 图片
            Stack({ alignContent: Alignment.Top }) {
              Row() {
                Row() {
                  Image(this.playState.img)
                    .width('70%')
                    .borderRadius(400)
                }
                .backgroundImage($r('app.media.ic_cd'))
                .backgroundImageSize(ImageSize.Cover)
                .justifyContent(FlexAlign.Center)
                .width('100%')
                .borderRadius(400)
                .clip(true)
                .aspectRatio(1)
                .shadow({
                  radius: 30,
                  color: this.randomColor
                })
                .rotate({
                  angle: this.rotateAngle
                })

              }
              .margin({
                top: 50
              })
              .width('90%')
              .aspectRatio(1)
              .justifyContent(FlexAlign.Center)
              .padding(24)

              // 唱针
              Image($r('app.media.ic_stylus'))
                .width(200)
                .aspectRatio(1)
                .rotate({
                  angle: this.playState.isPlay ? -45 : -55,
                  centerX: 100,
                  centerY: 30
                })
                .animation({
                  duration: 500
                })
            }

            // 歌曲信息
            Stack() {
              // 第一个
              Column({ space: 8 }) {
                Text(this.playState.name)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_dark'))
                Text(this.playState.author)
                  .fontSize(18)
                  .fontColor($r('app.color.primary_dark'))
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
              .zIndex(1)
              .translate({
                x: this.randomShakenX,
                y: this.randomShakenY
              })

              //第二个
              Column({ space: 8 }) {
                Text(this.playState.name)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_light'))
                Text(this.playState.author)
                  .fontSize(18)
                  .fontColor($r('app.color.primary_light'))
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
              .zIndex(2)
              .translate({
                x: this.randomShakenY,
                y: this.randomShakenX
              })

              // 第三个
              Column({ space: 8 }) {
                Text(this.playState.name)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                Text(this.playState.author)
                  .fontSize(18)
                  .fontColor(Color.White)
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
              .zIndex(3)
            }
            .layoutWeight(1)

            // 操作
            Row() {
              Badge({ value: '99+', style: { badgeSize: 12, badgeColor: '#45CCCCCC' } }) {
                Image($r("app.media.ic_like"))
                  .fillColor(Color.White)
                  .width(24)
              }

              Badge({ value: '10W', style: { badgeSize: 12, badgeColor: '#45cccccc' } }) {
                Image($r("app.media.ic_comment_o"))
                  .fillColor(Color.White)
                  .width(18)
              }

              Image($r("app.media.ic_sing"))
                .fillColor(Color.White)
                .width(24)


              Image($r("app.media.ic_download_o"))
                .fillColor(Color.White)
                .width(24)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)

            // 播放
            Column() {
              // 进度条
              Row({ space: 4 }) {
                Text(this.number2time(this.playState.time))
                  .fontSize(12)
                  .fontColor(Color.White)
                Slider({
                  value: this.playState.time,
                  min: 0,
                  max: this.playState.duration
                })
                  .layoutWeight(1)
                  .blockColor(Color.White)
                  .selectedColor(Color.White)
                  .trackColor('#ccc5c5c5')
                  .trackThickness(2)
                  .onChange((val) => {
                    // 拖拽进度
                  })
                Text(this.number2time(this.playState.duration))
                  .fontSize(12)
                  .fontColor(Color.White)
              }
              .width('100%')
              .padding(24)

              // 切换
              Row() {
                if (this.playState.playMode === 'auto') {
                  Image($r("app.media.ic_auto"))
                    .fillColor(Color.White)
                    .width(30)
                    .onClick(() => {
                      this.playState.playMode = 'repeat'
                    })
                } else if (this.playState.playMode === 'repeat') {
                  Image($r("app.media.ic_repeat"))
                    .fillColor(Color.White)
                    .width(30)
                    .onClick(() => {
                      this.playState.playMode = 'random'
                    })
                } else if (this.playState.playMode === 'random') {
                  Image($r("app.media.ic_random"))
                    .fillColor(Color.White)
                    .width(30)
                    .onClick(() => {
                      this.playState.playMode = 'auto'
                    })
                }
                // 前一首
                Image($r('app.media.ic_prev'))
                  .fillColor(Color.White)
                  .width(30)
                  .onClick(() => {
                    // 上一首
                  })

                // 播放按钮
                Image(this.playState.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
                  .fillColor(Color.White)
                  .width(50)
                  .onClick(() => {
                    // 如果能点才执行逻辑
                    // 播放及动画
                  })
                // 下一首
                Image($r('app.media.ic_next'))
                  .fillColor(Color.White)
                  .width(30)
                  .onClick(() => {
                    // 下一首
                  })
                // 播放列表
                Image($r('app.media.ic_song_list'))
                  .fillColor(Color.White)
                  .width(30)
                  .onClick(() => {
                    this.panelHeight = '100%'
                  })
              }
              .width('100%')
              .padding({
                bottom: 24
              })
              .justifyContent(FlexAlign.SpaceAround)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width('100%')
        }
      }
      .backgroundColor(Color.Transparent)

      // 列表
      Column() {
        Column() {

        }
        .width('100%')
        .layoutWeight(1)
        .onClick(() => {
          this.panelHeight = '0%'
        })

        Column() {
          Row() {
            Row() {
              Image($r("app.media.ic_play"))
                .width(20)
                .fillColor('#ff5186')
            }
            .width(50)
            .aspectRatio(1)
            .justifyContent(FlexAlign.Center)

            Row({ space: 8 }) {
              Text(`播放列表 (${this.playState.playList?.length})`)
                .fontColor(Color.White)
                .fontSize(14)
            }
            .layoutWeight(1)

            Image($r('app.media.ic_close'))
              .fillColor('#ffa49a9a')
              .width(24)
              .height(24)
              .margin({ right: 16 })
              .onClick(() => {
                this.panelHeight = '0%'
              })
          }
          .width('100%')
          .backgroundColor('#ff353333')
          .padding(8)
          .border({
            width: { bottom: 1 },
            color: '#12ec5c87'
          })
          .borderRadius({
            topLeft: 4,
            topRight: 4
          })

          // 播放列表
          List() {
            ForEach(this.playState.playList, (item: songItemType, index: number) => {
              ListItem() {
                Row() {
                  Row() {
                    Text((index + 1).toString())
                      .fontColor('#ffa49a9a')
                  }
                  .width(50)
                  .aspectRatio(1)
                  .justifyContent(FlexAlign.Center)

                  // 列表
                  Row({ space: 10 }) {
                    Column() {
                      Text(item.name)
                        .fontSize(14)
                        .fontColor(this.playState.playIndex === index ? $r('app.color.primary_light') : '#ffa49a9a')
                      Text(item.author)
                        .fontSize(12)
                        .fontColor(this.playState.playIndex === index ? $r('app.color.primary_light') : Color.Gray)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Center)
                  }
                  .layoutWeight(1)

                  Image($r('app.media.ic_more'))
                    .width(24)
                    .height(24)
                    .margin({ right: 16 })
                    .fillColor(Color.Gray)
                }
                .alignItems(VerticalAlign.Center)
              }
              .onClick(() => {
                // 播放
              })
              .swipeAction({
                end: this.deleteButton(index)
              })
              .border({
                width: { bottom: 1 },
                color: '#12ec5c87'
              })
            })
          }
          .layoutWeight(1)
          .backgroundColor('#ff353333')

        }
        .height(400)
      }
      .height(this.panelHeight)
      .animation({
        duration: 300
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .opacity(this.opacityNum)
  }

  // 页面也换效果,避免滑动切换效果
  pageTransition() {
    PageTransitionEnter({ duration: 200 })
      .onEnter(() => {
        this.opacityNum = 1
      })
    PageTransitionExit({ duration: 200 })
      .onExit(() => {
        this.opacityNum = 0
      })
  }
}

