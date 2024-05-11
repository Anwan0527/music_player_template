import commonEventManager from '@ohos.commonEventManager'
import { PublishEventType } from '../constants/EventContants'
export class SubscriberClass {
  static publishCount:number = 1
  static publish(eventType:PublishEventType,data:string){
    // next中data支持导入类型
    commonEventManager.publish(eventType,{data},(err)=>{
      if(err){
        // 失败只发3次
        if(SubscriberClass.publishCount<=3){
          SubscriberClass.publish(PublishEventType.CARD_PUBLISH,data)
          SubscriberClass.publishCount++
        }else{
          SubscriberClass.publishCount = 1
        }
      }else{
        SubscriberClass.publishCount = 1
      }
    })
  }
  static subscribe(eventType:PublishEventType,subscriber:commonEventManager.CommonEventSubscriber,callback:(event:string)=>void){
    commonEventManager.createSubscriber({ events: [eventType] }, (err, data) => {
      if (err) {
        return console.log('logData:', `创建订阅者error ${JSON.stringify(err)}`)
      }
      console.log('logData:', `创建订阅者success`)
      subscriber = data
      if (subscriber !== null) {
        //订阅事件
        commonEventManager.subscribe(subscriber, (err, data) => {
          if (err) {
            return console.error(`logData`, '订阅事件失败')
          }
          console.log('logData:',`接受订阅事件:${data.data}`)
          callback(data.data as string)
        })
      } else {
        console.error('logData:',`需要创建subscriber`);
      }
    })
  }
}