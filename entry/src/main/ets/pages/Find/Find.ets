import { songs } from '../../constants/index'
import { songItemType } from '../../models/index'
@Entry
@Component
struct Find {
  build() {
    Column() {
      Row() {
        Text('猜你喜欢').fontColor('#eaeaec')
      }
      .padding(24)
      .width('100%')
      Row(){
        List({space:12}) {
          ForEach(songs,(item:songItemType,index:number)=>{
            ListItem() {
              Row({space:12}) {
                Row() {
                  Image(item.img)
                    .borderRadius(8)
                    .width(60)
                }
                Column({space:12}) {
                  Text(item.name).fontColor('#e9e9e7')
                  Row({space:4}){
                    Text('VIP') .fontSize(10)
                      .padding({
                        left:6,
                        right:6,
                        top:2,
                        bottom:2
                      })
                      .border({
                        width:1,
                        color:'#c0a267'
                      }).borderRadius(10).fontColor('#c0a267')
                    Text(item.author)
                      .fontColor('#aaa9af')
                      .fontSize(12)
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Row() {
                  Image($r('app.media.ic_more'))
                    .fillColor('#aaa9af')
                    .width(24)
                }
              }
            }.onClick(() => {
              // 播放

            })

          })
          ListItem() {
            Row() {
              Text('我是有底线的~')
                .fontColor(Color.Gray)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(16)
          }
        }.width('100%').height('100%')
        .padding({
          left:24,
          right:24
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}

export default Find