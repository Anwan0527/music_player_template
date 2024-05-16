import AvSession from '@ohos.multimedia.avsession'
import AVPlayerManger from './AVPlayerManger'
import { songItemType } from '../models'

export default class AvSessionManager {
  static session: AvSession.AVSession
  static controller: AvSession.AVSessionController

  // 初始化媒体会话
  static async init(context: Context) {
    AvSessionManager.session = await AvSession.createAVSession(context, 'bgPlay', 'audio') // 拿到会话对象
    AvSessionManager.controller = await AvSessionManager.session.getController() // 拿到会话控制器
    AvSessionManager.registerEvent()
  }

  // 设置媒体资源
  static async setAvMetaData(song: songItemType) {
    await AvSessionManager.session.setAVMetadata({
      assetId: song.id,
      title: song.name,
      artist: song.author,
      mediaImage: song.img,
      duration: AVPlayerManger.currentSong.duration
    })
  }

  // 设置状态方法
  static async setAVPlaybackState() {
    AvSessionManager.session.setAVPlaybackState({
      state: AVPlayerManger.currentSong.isPlay ? AvSession.PlaybackState.PLAYBACK_STATE_PLAY :
      AvSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: AVPlayerManger.currentSong.time,
        updateTime: (new Date()).getTime(),
      },
      speed: 1.0,
      duration: AVPlayerManger.currentSong.duration
    })
  }
  static async registerEvent () {
    AvSessionManager.session.on('play', () => {
      AVPlayerManger.singlePlay(AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex])
    })
    AvSessionManager.session.on('pause', () => {
      AVPlayerManger.pause()
    })
    AvSessionManager.session.on('stop', () => {
    })
    AvSessionManager.session.on('playNext', () => {
      AVPlayerManger.nextPlay()
    })
    AvSessionManager.session.on('playPrevious', () => {
      AVPlayerManger.prevPlay()
    })
    AvSessionManager.session.on('seek', (time) => {
      AVPlayerManger.player!.seek(time)
    })
    AvSessionManager.session.activate()
  }
}