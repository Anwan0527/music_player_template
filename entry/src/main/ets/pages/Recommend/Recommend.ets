import { swiperList, recommendList, dailyRecommend } from '../../constants/index'
import { recommendListType, recommendDailyType } from '../../models/index'

@Entry
@Component
struct Recommend {
  @State
  value: number  = 10
  @Builder
  SearchInput() {
    Row() {
      Row({ space: 4 }) {
        Image($r('app.media.ic_search'))
          .width(20)
          .aspectRatio(1)
          .fillColor('#7a828e')
        Text('只因你太美🔥')
          .fontColor('#7a828e')
          .layoutWeight(1)
        Image($r('app.media.ic_code'))
          .width(20)
          .aspectRatio(1)
          .fillColor('#7a828e')
      }
      .width('100%')
      .padding(12)
      .borderRadius('60')
      .backgroundColor('#FF2D2A2A')
    }
    .width('100%')
    .padding(12)
  }

  @Builder
  SwiperComponent() {
    Row() {
      Swiper() {
        ForEach(swiperList, (item: string) => {
          Row() {
            Image(item)
              .width('100%')
          }
          .borderRadius(8)
          .clip(true)
        })
      }
      .margin(8)
      .autoPlay(true)

    }
    .width('100%')
    .padding(12)
  }

  @Builder
  TitleBar(title: string) {
    // 标题
    Row() {
      Text(title)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
      Text('更多')
        .fontColor(Color.Gray)
    }
    .width('100%')
    .padding(8)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Scroll() {
      Column() {

        //   搜索框
        this.SearchInput()
        //   轮播图
        this.SwiperComponent()
        //   每日推荐
        Column() {
          this.TitleBar('每日推荐')
          Row() {
            Scroll() {
              Row({ space: 10 }) {
                ForEach(dailyRecommend, (item: recommendDailyType) => {
                  Column() {
                    Text(item.type)
                      .width('100%')
                      .textAlign(TextAlign.Start)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                      .fontSize(12)
                      .padding(8)
                      .backgroundColor(item.top)
                    Stack({ alignContent: Alignment.Top }) {
                      Image(item.img)
                        .width('100%')
                        .aspectRatio(1)
                    }

                    Text(item.title)
                      .width('100%')
                      .fontSize(12)
                      .padding(12)
                      .fontColor('#FFE9DFDF')
                      .backgroundColor(item.bottom)
                      .maxLines(2)
                      .textOverflow({
                        overflow:TextOverflow.Ellipsis
                      })
                  }
                  .width('40%')
                  .borderRadius(8)
                  .clip(true)
                })
              }
            }
            .width('100%')
            .scrollable(ScrollDirection.Horizontal)
            .scrollBarWidth(0)
          }
          .padding({
            left: 8,
            right: 8
          })
        }
        //   推荐歌单
        Column() {
          this.TitleBar('推荐歌单')
          // 歌单项
          Row() {
            Scroll() {
              Row({ space: 8 }) {
                ForEach(recommendList, (item: recommendListType) => {
                  Column() {
                    Row() {
                      Image(item.img)
                        .width('100%')
                        .borderRadius(8)
                      Text(item.count)
                        .fontColor(Color.White)
                        .fontSize(12)
                        .fontWeight(FontWeight.Bold)
                        .position({
                          x: 6,
                          y: 6
                        })
                    }

                    Text(item.title)
                      .textAlign(TextAlign.Start)
                      .fontSize(12)
                      .fontColor('#FFE9DFDF')
                      .maxLines(2)
                      .textOverflow({
                        overflow: TextOverflow.Ellipsis
                      })
                      .margin({
                        top: 8
                      })
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .width('30%')
                })
              }
            }
            .width('100%')
            .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
          }
          .padding({
            left: 8,
            right: 8
          })
        }
      }.width('100%')
    }.height('100%')
  }
}

export default Recommend