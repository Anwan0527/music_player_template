import avSession from '@ohos.multimedia.avsession'
import { wantAgent } from '@kit.AbilityKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { songItemType } from '../models'
import AvPlayerManager from './AvPlayerManger'

export default class AvSessionManager {
  static session: avSession.AVSession
  static controller: avSession.AVSessionController

  //初始化媒体会话
  static async init(context: Context) {
    AvSessionManager.session = await avSession.createAVSession(context, 'bgPlay', 'audio')
    AvSessionManager.controller = await AvSessionManager.session.getController() //拿到会话控制器
    AvSessionManager.registerEvent()
  }

  //开启后台任务
  static async startBackgroundTask() {
    if (AvSessionManager.session.sessionId) {
      //如果有会话id 则不用开启后台任务
      return
    }
    try {
      let wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: 'com.example.heimacloudmusic',
            abilityName: 'EntryAbility'
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
      const want = await wantAgent.getWantAgent(wantAgentInfo) //获取want信息
      await backgroundTaskManager.startBackgroundRunning(getContext(),
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, want)
    } catch (e) {
      AlertDialog.show({
        message: e.message
      })
    }
  }

  //设置媒体资源
  static async setAvmMeteData(song: songItemType) {
    await AvSessionManager.session.setAVMetadata({
      assetId: song.id,
      title: song.name,
      artist: song.author,
      mediaImage: song.img,
      duration: AvPlayerManager.currentSong.duration
    })
  }

  //设置状态方法
  static async setAVPlaybackState() {
    AvSessionManager.session.setAVPlaybackState({
      state: AvPlayerManager.currentSong.isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
      avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: AvPlayerManager.currentSong.time,
        updateTime: (new Date()).getTime()
      },
      speed: 1.0,
      duration: AvPlayerManager.currentSong.duration
    })
  }

  //当点击播控中心的播放-下一首-上一首时进行处理
  static async registerEvent() {
    AvSessionManager.session.on('play', () => {
      AvPlayerManager.singlePlay(AvPlayerManager.currentSong.playList[AvPlayerManager.currentSong.playIndex])
    })
    AvSessionManager.session.on('pause', () => {
      AvPlayerManager.pause()
    })
    AvSessionManager.session.on('stop', () => {
      //没错这里没有
    })
    AvSessionManager.session.on('playNext', () => {
      AvPlayerManager.nextPlay()
    })
    AvSessionManager.session.on('playPrevious', () => {
      AvPlayerManager.prevPlay()
    })
    AvSessionManager.session.on('seek', (time) => {
      AvPlayerManager.player!.seek(time)
    })
    AvSessionManager.session.activate()
  }
}