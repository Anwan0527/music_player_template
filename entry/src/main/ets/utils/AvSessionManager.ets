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
}