import { emitter } from '@kit.BasicServicesKit'
import animator, { AnimatorResult } from '@ohos.animator';
import AudioCapturer from '../utils/AudioCapturer'
import { util } from '@kit.ArkTS'
import AVPlayerClass from '../utils/AVPlayerClass';
import AudioRender from '../utils/AudioRender';
import display from '@ohos.display';
import { promptAction } from '@kit.ArkUI';
import { PlayStateType } from '../models/playState';

interface lyricType {
  start: number
  end: number
  word: string
}

interface lyricInfoType {
  name: string
  src: string
  lyric: lyricType[]
}

@Entry
@Component
struct Play {
  @State
  playState: PlayStateType = {} as PlayStateType
  @State
  musicVol: number = 40
  @State
  personVol: number = 100
  @State
  lyricInfo: lyricInfoType = {} as lyricInfoType
  @State
  activeIndex: number = 0
  @State
  screenX: number = 0
  @State
  lyricProgress: number = 0
  scrollerForList: Scroller = new Scroller()
  animator: AnimatorResult = {} as AnimatorResult
  @State
  soundTrack: number[] = []
  @State
  sumSound: number = 0
  @State
  avrCount: number = 0
  @State
  flag: boolean = true
  trackNum: number = 15

  number2time(number: number) {
    const second = Math.floor(number / 1000)
    if (second >= 60) {
      const m = Math.floor(second / 60)
      return `${m.toString().padStart(2, '0')}:${(second % 60).toString().padStart(2, '0')}`
    } else {
      return `00:${second.toString().padStart(2, '0')}`
    }
  }

  async aboutToAppear(): Promise<void> {
    // 获取屏幕宽度
    const displays = await display.getDefaultDisplaySync()
    this.screenX = px2vp(displays.width)
    emitter.on({ eventId: 0 }, (data) => {
      this.playState = data.data as PlayStateType
      // 查找歌词
      const index = this.lyricInfo.lyric.findIndex(item => {
        return this.playState.time >= item.start && this.playState.time < item.end
      })
      if (index !== -1 && index !== this.activeIndex) {
        this.activeIndex = index
        //     更新动画
        this.animator.reset({
          duration: this.lyricInfo.lyric[index].end - this.lyricInfo.lyric[index].start,
          easing: "liner",
          delay: 0,
          fill: "none",
          direction: "normal",
          iterations: 1,
          begin: 0,
          end: this.screenX
        })
        this.animator.play()
        this.scrollerForList.scrollToIndex(this.activeIndex === -1 ? 0 : this.activeIndex, true)
      }
    })
    emitter.on({ eventId: 1 }, (data) => {
      this.sumSound += data.data!.avr
      this.avrCount++
      if (this.flag) {
        this.flag = false
        setTimeout(() => {
          this.flag = true
          this.soundTrack.unshift(this.sumSound / this.avrCount)
          if (this.soundTrack.length >= this.trackNum) {
            this.soundTrack.pop()
          }
          this.sumSound = 0
          this.avrCount = 0
        }, 60)
      }
    })
    this.animator = animator.create({
      duration: 5 * 1000,
      easing: "liner",
      delay: 0,
      fill: "backwards",
      direction: "normal",
      iterations: 1,
      begin: 0,
      end: this.screenX
    })
    this.animator.onframe = (val) => {
      this.lyricProgress = val
    }
    // 读取json歌词文件
    const data = getContext().resourceManager.getRawFileContentSync('test.json')
    const decoder = util.TextDecoder.create()
    const json = decoder.decodeWithStream(data)
    this.lyricInfo = JSON.parse(json) as lyricInfoType
    //   播放+录音
    AudioCapturer.start(this.lyricInfo.src, getContext(this))
    this.animator.play()
  }
  aboutToDisappear(): void {
    AudioCapturer.stop()
    AudioRender.stop()
    AVPlayerClass.player.reset()
    AVPlayerClass.isPlay = false
    AVPlayerClass.time = 0
    AVPlayerClass.updateState()
  }
  build() {
    // 播放
    Column() {
      // 标题
      Row() {
        Text('K歌模式')
          .fontColor(Color.White)
          .fontSize(24)
      }
      .width('100%')
      .padding(12)
      .justifyContent(FlexAlign.Center)

      // 歌词
      Column() {
        Blank()
          .layoutWeight(1)
        Column() {
          List({ scroller: this.scrollerForList }) {
            ForEach(this.lyricInfo.lyric, (lyric: lyricType, index: number) => {
              ListItem() {
                Stack({ alignContent: Alignment.Start }) {
                  Text(lyric.word)
                    .textAlign(TextAlign.Center)
                    .fontSize(index === this.activeIndex ? 24 : 14)
                    .fontColor('#fff')
                    .fontWeight(FontWeight.Bold)
                    .padding(12)
                    .width('100%')

                  if (this.activeIndex === index) {
                    Row() {
                      Text(lyric.word)
                        .textAlign(TextAlign.Center)
                        .fontSize(index === this.activeIndex ? 24 : 14)
                        .fontColor('#ec5c87')
                        .fontWeight(FontWeight.Bold)
                        .padding(12)
                        .width(this.screenX)
                    }
                    .width(this.lyricProgress)
                    .clip(true)
                  }
                }
              }
            })
          }
          .scrollBarWidth(0)
        }
        .width('100%')
        .height(150)

        Blank()
          .layoutWeight(1)
      }.width('100%')
      .layoutWeight(1)

      // 音轨
      Row() {
        ForEach(this.soundTrack, (item: number) => {
          Column() {
          }
          .backgroundColor('#ec5c87')
          .height(item)
          .layoutWeight(1)
        })
      }
      .animation({
        duration: 300
      })
      .alignSelf(ItemAlign.End)
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .height(300)

      // 音乐声音
      Row({ space: 4 }) {
        Text('音乐：')
          .fontSize(12)
          .fontColor(Color.White)
        Slider({
          value: this.musicVol,
          min: 0,
          max: 100
        })
          .layoutWeight(1)
          .blockColor(Color.White)
          .selectedColor(Color.White)
          .trackColor('#ccc5c5c5')
          .trackThickness(2)
          .onChange((val) => {
            this.musicVol = val
            AVPlayerClass.player.setVolume(val / 100)
          })
      }
      .width('100%')
      .padding(12)

      // 人声
      Row({ space: 4 }) {
        Text('人声：')
          .fontSize(12)
          .fontColor(Color.White)
        Slider({
          value: this.personVol,
          min: 0,
          max: 100
        })
          .layoutWeight(1)
          .blockColor(Color.White)
          .selectedColor(Color.White)
          .trackColor('#ccc5c5c5')
          .trackThickness(2)
          .onChange((val) => {
            this.personVol = val
            AudioRender.renderer.setVolume(val / 100)
          })
      }
      .width('100%')
      .padding(12)

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
              AVPlayerClass.player.seek(val)
            })
          Text(this.number2time(this.playState.duration))
            .fontSize(12)
            .fontColor(Color.White)
        }
        .width('100%')
        .padding(12)

        // 切换
        Row() {
          // 录制BGM
          Button('重新录制')
            .onClick(() => {
              AudioCapturer.restart(this.lyricInfo.src, getContext(this))
              promptAction.showToast({
                message:'重新录制'
              })
            })
          // 人声录制
          Button('停止录制')
            .onClick(() => {
              AudioCapturer.stop()
              promptAction.showToast({
                message:'停止录制'
              })
            })
          // 播放录制
          Button('播放录音')
            .onClick(() => {
              AudioRender.play(AudioCapturer.filePath)
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
    .width('100%')
    .height('100%')
    // .backgroundImage(this.playState.img)
    // .backgroundImageSize(ImageSize.Cover)
    .backgroundColor('#4bb0c4')
    // .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}