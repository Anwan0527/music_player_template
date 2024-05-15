import { media } from '@kit.MediaKit'
import {  PlayStateType } from '../models/playState'
import { BusinessError, commonEventManager, emitter } from '@kit.BasicServicesKit'
import { Context, wantAgent } from '@kit.AbilityKit'
import { PreferencesClass } from './PreferencesClass'
import { formBindingData, formProvider } from '@kit.FormKit'
import { SubscriberClass } from './SubscriberClasss'
import { EmitEventType, PublishEventType } from '../constants/EventContants'
import { Http2BufferClass } from './requestClass'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import AVSessionClass from './AVSessionClass'
import { songItemType } from '../models'
import { router } from '@kit.ArkUI'

export default class AVPlayerClass {
  //   属性
  //   1.播放器
  static player: media.AVPlayer = {} as media.AVPlayer
  //   2.歌曲时长
  static duration: number = 0
  //   3.播放时长
  static time: number = 0
  //   4.是否播放
  static isPlay: boolean = false
  //   5.播放模式
  static playMode: 'auto' | 'repeat' | 'random' = 'auto'
  //   6.播放列表
  static playList: songItemType[] = []
  //   7.播放索引
  static playIndex: number = 0
  //   8.上下文
  static context: Context = {} as Context
  //   9.订阅者
  static cardSubscriber: commonEventManager.CommonEventSubscriber
  //   10.首选项
  static preferences: PreferencesClass

  //   方法
  // 1.初始化播放器
  static async init(context: Context) {
    // 记录上下文
    AVPlayerClass.context = context
    // 读取首选项的播放状态
    AVPlayerClass.preferences = new PreferencesClass(context)
    // AVPlayerClass.preferences
    // 并且更新（防止应用强杀导致的状态不一样）
    const playState = AVPlayerClass.preferences.getPlayState()
    playState.isPlay = false
    if (playState.url !== '') {
      AVPlayerClass.time = playState.time
      AVPlayerClass.duration = playState.duration
      AVPlayerClass.playIndex = playState.playIndex
      AVPlayerClass.playList = playState.playList
      AVPlayerClass.playMode = playState.playMode
      // 回写首选项(更新强杀后的播放状态)
    }
    await AVPlayerClass.preferences.setPlayState(playState)
    // 监听卡片发送的事件
    SubscriberClass.subscribe(PublishEventType.CARD_PUBLISH, AVPlayerClass.cardSubscriber, (event) => {
      switch (event) {
        case 'next':
          AVPlayerClass.playNext()
          break
        case 'prev':
          AVPlayerClass.playPrevious()
          break
        default:
        // event是卡片ID
          AVPlayerClass.preferences.setFormId(event)
      }
    })
    // 创建一个播放器  记录再实例的player属性上
    AVPlayerClass.player = await media.createAVPlayer()
    AVPlayerClass.player.setVolume(40 / 100)
    //  监听播放器的状态
    AVPlayerClass.player.on('stateChange', async (state) => {
      switch (state) {
      // 初始化状态
        case 'initialized':
        // 准备
          AVPlayerClass.player.prepare()
          break
      //   准备状态
        case 'prepared':
          AVPlayerClass.player.play()
          break
      // paused周期不稳定，和update冲突
      // case 'paused':
      //   console.log('logData-paused')
      //   break
      // 播放完成
        case 'completed':
          if (AVPlayerClass.playMode === 'random' && AVPlayerClass.playList.length > 1) {
            let index = 0
            do {
              index = Math.floor(Math.random() * AVPlayerClass.playList.length)
            } while (index === AVPlayerClass.playIndex)
            // 已经拿到了非自身的索引
            AVPlayerClass.playIndex = index
          } else if (AVPlayerClass.playMode === 'auto') {
            AVPlayerClass.playIndex++
            AVPlayerClass.playIndex = (AVPlayerClass.playIndex + AVPlayerClass.playList.length) % AVPlayerClass.playList.length
          }
          AVPlayerClass.singlePlay(AVPlayerClass.playList[AVPlayerClass.playIndex])
          break
      }
    })
    //  监听播放器的歌曲时长
    AVPlayerClass.player.on('durationUpdate', async (duration) => {
      AVPlayerClass.duration = duration
      await AVSessionClass.setAVMetadata(AVPlayerClass.playList[AVPlayerClass.playIndex])
    })
    //  监听播放器的播放时长
    AVPlayerClass.player.on('timeUpdate', async (time) => {
      // 防止seek走0秒update
      AVPlayerClass.time = time
      // 发布出去
      AVPlayerClass.updateState()
    })
    //  监听设置播放时长
    // AVPlayerClass.player.on('seekDone', () => {
    //   AVPlayerClass.isPlay = true
    //   AVPlayerClass.player.play()
    // })


  }

  // 2.单曲播放
  static async singlePlay(song: songItemType) {
    AVPlayerClass.startBackground()
    const index = AVPlayerClass.playList.findIndex(item => item.id === song.id)
    if (index >= 0) {
      //正在播放
      if (AVPlayerClass.player.url === song.url) {
        // 当前是否正在播放
        if (AVPlayerClass.isPlay) {
          // 重新播放
          AVPlayerClass.time = 0
          await AVPlayerClass.changePlay(song.url)
        } else {
          // 继续播放(设置播放器到指定的时间)
          // await AVPlayerClass.player.seek(AVPlayerClass.time)
          AVPlayerClass.player.play()
          AVPlayerClass.isPlay = true
        }
      }
      else {
        // 断点续播
        if (AVPlayerClass.player.url === '') {
          // 继续播放
          await AVPlayerClass.changePlay(song.url)
        } else {
          // 切换歌曲(切的索引)else
          AVPlayerClass.playIndex = index
          AVPlayerClass.time = 0
          await AVPlayerClass.changePlay(song.url)
        }
      }
    }
    else {
      AVPlayerClass.playList.unshift(song)
      AVPlayerClass.playIndex = 0
      AVPlayerClass.time = 0
      AVPlayerClass.changePlay(song.url)
    }
    //   通知卡片
    AVPlayerClass.updateCard(song.img)

  }

  // 3.发布信息
  static async updateState() {
    const data: PlayStateType = {
      duration: AVPlayerClass.duration,
      time: AVPlayerClass.time,
      isPlay: AVPlayerClass.isPlay,
      playMode: AVPlayerClass.playMode,
      playList: AVPlayerClass.playList,
      playIndex: AVPlayerClass.playIndex,
      img: AVPlayerClass.playList[AVPlayerClass.playIndex].img,
      name: AVPlayerClass.playList[AVPlayerClass.playIndex].name,
      author: AVPlayerClass.playList[AVPlayerClass.playIndex].author,
      url: AVPlayerClass.playList[AVPlayerClass.playIndex].url
    }
    emitter.emit({
      eventId: EmitEventType.UPDATE_STATE
    }, {
      data
    })
    //   通知首选项
    // 回写首选项(更新强杀后的播放状态)
    // await AVPlayerClass.preferences.setPlayState(data)
    //   通知控制中心
    await AVSessionClass.setAVPlaybackState()
    //   通知卡片
    AVPlayerClass.updateCard(data.img)
  }

  // 4.下载图片更新卡片
  static async updateCard(img: string) {
    // 通知卡片start
    const id: string = AVPlayerClass.preferences.getFormId()
    if (!id) return
    Http2BufferClass.get(img, AVPlayerClass.context, (result) => {
      formProvider.updateForm(id, formBindingData.createFormBindingData({
        playState: Date.now(),
        // 展示使用
        fileName: result.fileName,
        // 必须得传
        formImages: result.formImages
      }))
    })
    // 通知卡片end
  }

  // 4.上一首
  static playPrevious() {
    AVPlayerClass.playIndex--
    AVPlayerClass.playIndex = AVPlayerClass.playIndex < 0 ? AVPlayerClass.playList.length - 1 : AVPlayerClass.playIndex
    AVPlayerClass.singlePlay(AVPlayerClass.playList[AVPlayerClass.playIndex])
  }

  // 5.下一首
  static playNext() {
    AVPlayerClass.playIndex++
    AVPlayerClass.playIndex = AVPlayerClass.playIndex > AVPlayerClass.playList.length - 1 ? 0 : AVPlayerClass.playIndex
    AVPlayerClass.singlePlay(AVPlayerClass.playList[AVPlayerClass.playIndex])
  }

  // 6.删除列表
  static async remove(index: number) {
    // 当前是否正在播放这首歌曲
    if (AVPlayerClass.playIndex === index) {
      //  删完还有歌曲吗?
      if (AVPlayerClass.playList.length > 1) {
        AVPlayerClass.playList.splice(index, 1)
        // 切换歌曲前,要计算出切换歌曲的索引
        // 复杂点:有一定的计算逻辑需要理解,如果不能理解那就if else
        AVPlayerClass.playIndex = (AVPlayerClass.playIndex + AVPlayerClass.playList.length) % AVPlayerClass.playList.length
        AVPlayerClass.singlePlay(AVPlayerClass.playList[AVPlayerClass.playIndex])
      } else {
        // 返回上一页
        // 播放停止了
        await AVPlayerClass.player.reset()
        AVPlayerClass.playList.splice(index, 1)
        AVPlayerClass.isPlay = false
        AVPlayerClass.duration = 0
        AVPlayerClass.time = 0
        // 问题:由于我已经重置状态机了,所以没有给页面推送我删除后的状态
        // this.updateState()
        // 因为删除完了,playList是空数组了,不能用this.playList[].url的写法了
        const data: PlayStateType = new PlayStateType()
        // 1.推送到了页面
        emitter.emit({
          eventId: EmitEventType.UPDATE_STATE
        }, {
          data
        })
        // 2.推送到首选项
        await AVPlayerClass.preferences.setPlayState(data)
        router.back()
      }
    } else {
      // 删除播放前面的
      if (AVPlayerClass.playIndex > index) {
        AVPlayerClass.playIndex--
      }
      AVPlayerClass.playList.splice(index, 1)
    }
  }

  // 切换歌曲url
  static async changePlay(url: string) {
    await AVPlayerClass.player.reset()
    AVPlayerClass.isPlay = true
    AVPlayerClass.player.url = url
  }

  // 暂停歌曲
  static pause() {
    AVPlayerClass.isPlay = false
    AVPlayerClass.player.pause()
    AVSessionClass.setAVPlaybackState(true)
    backgroundTaskManager.stopBackgroundRunning(AVPlayerClass.context, () => {
    })
    AVPlayerClass.updateState()
  }

  //   后台播放
  static startBackground() {
    // 媒体回话start
    AVSessionClass.setAVMetadata(AVPlayerClass.playList[AVPlayerClass.playIndex])
    // 媒体回话end
    // 后台播放start
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.example.heimacloudmusic",
          abilityName: "EntryAbility"
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj) => {
      backgroundTaskManager.startBackgroundRunning(AVPlayerClass.context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj, () => {
        })
    })
    // 后台播放end
  }
}