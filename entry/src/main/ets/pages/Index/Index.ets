import { TabClass } from '../../models'
import { tabsData } from '../../constants/index'
import Find from '../Find/Find'
import Mine from '../Mine/Mine'
import Moment from '../Moment/Moment'
import Recommend from '../Recommend/Recommend'
import SongList from '../SongList/SongList'
import router from '@ohos.router'
import PlayerNav from '../../components/playerNav'
import {  PlayStateType } from '../../models/playState'
import { SONG_KEY } from '../../constants'

@Entry
@Component
struct HomeIndex {
  @State
  currentName: string = 'recommend'
  @State
  opacityNum: number = 1
  @StorageLink(SONG_KEY)
  playState: PlayStateType = new PlayStateType()

  // tabBar组件
  @Builder
  getTabBar(item: TabClass) {
    Column() {
      Row() {
        Image(item.icon)
          .fillColor(item.name === this.currentName ? Color.White : $r('app.color.primary_dark'))
          .width(item.name === this.currentName ? 18 : 22)
          .aspectRatio(1)
      }
      .width(22)
      .aspectRatio(1)
      .borderRadius(22)
      .backgroundColor(item.name === this.currentName ? $r('app.color.primary_light') : Color.Transparent)
      .justifyContent(FlexAlign.Center)

      Text(item.title)
        .fontSize(12)
        .fontWeight(400)
        .margin({ top: 5 })
        .fontColor(item.name === this.currentName ? $r('app.color.primary_light') : $r('app.color.primary_dark'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ barPosition: BarPosition.End }) {
          ForEach(tabsData, (item: TabClass) => {
            TabContent() {
              if (item.name === 'recommend') {
                Recommend()
              } else if (item.name === 'find') {
                Find()
              } else if (item.name === 'moment') {
                Moment()
              } else if (item.name === 'mine') {
                Mine({ playState: $playState })
              } else {
                SongList()
              }
            }
            .tabBar(this.getTabBar(item))
            .backgroundColor('#3c3f41')
          })
        }
        .barHeight(60)
        .onChange(index => {
          this.currentName = tabsData[index].name
        })

        // 背景播放
        PlayerNav()
          .translate({ y: -60 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Play/Play'
            })
          })
          .visibility(this.playState.playList.length > 0 && this.currentName !== 'mine' ? Visibility.Visible : Visibility.Hidden)

      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#3c3f41')
    .opacity(this.opacityNum)
    .padding({
      top: AppStorage.get("topHeight"),
      bottom: AppStorage.get("bottomHeight")
    })
  }
}


