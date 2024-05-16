import avSession from '@ohos.multimedia.avsession'
import { Context } from '@kit.AbilityKit';
import { songItemType } from '../models/music';
import { BusinessError } from '@kit.BasicServicesKit';
import AVPlayerClass from './AVPlayerClass';
import { router } from '@kit.ArkUI';

export default class AVSessionClass {
  static currentSession: avSession.AVSession
  static sessionId: string = ''
  static controller: avSession.AVSessionController
  static isSettingState: boolean = false

  static init(context: Context) {
    avSession.createAVSession(context, 'bgPlay', 'audio').then((data: avSession.AVSession) => {
      AVSessionClass.currentSession = data;
      AVSessionClass.sessionId = data.sessionId;
      data.getController().then((controller: avSession.AVSessionController) => {
        AVSessionClass.controller = controller
      })
    }).catch((err: BusinessError) => {
      console.info(`CreateAVSession BusinessError: code: ${err.code}, message: ${err.message}`);
    });
  }

  static async setAVMetadata(song: songItemType) {
    await AVSessionClass.currentSession.setAVMetadata({
      assetId: song.id,
      title: song.name,
      artist: song.author,
      mediaImage: song.img,
      duration: AVPlayerClass.duration
    })
    AVSessionClass.registerController()
  }

  static setAVPlaybackState(now?: boolean) {
    if (now) {
      AVSessionClass.currentSession.setAVPlaybackState({
        state: AVPlayerClass.isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: AVPlayerClass.time,
          updateTime: (new Date()).getTime(),
        },
        speed: 1.0,
        duration: AVPlayerClass.duration
      })
    } else {
      if (!AVSessionClass.isSettingState) {
        AVSessionClass.isSettingState = true
        AVSessionClass.currentSession.setAVPlaybackState({
          state: AVPlayerClass.isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
          avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
          position: {
            elapsedTime: AVPlayerClass.time,
            updateTime: (new Date()).getTime(),
          },
          speed: 1.0,
          duration: AVPlayerClass.duration
        }).then(() => {
          AVSessionClass.isSettingState = false
        })
      }
    }

  }

  static registerController() {
    AVSessionClass.currentSession.on('play', () => {
      AVPlayerClass.singlePlay(AVPlayerClass.playList[AVPlayerClass.playIndex])
    })
    AVSessionClass.currentSession.on('pause', () => {
      AVPlayerClass.pause()
    })
    AVSessionClass.currentSession.on('stop', () => {
    })
    AVSessionClass.currentSession.on('playNext', () => {
      AVPlayerClass.playNext()
    })
    AVSessionClass.currentSession.on('playPrevious', () => {
      AVPlayerClass.playPrevious()
    })
    AVSessionClass.currentSession.on('seek', (time) => {
      AVPlayerClass.player.seek(time)
    })
    AVSessionClass.currentSession.on('outputDeviceChange',
      (state: avSession.ConnectionState, device: avSession.OutputDeviceInfo) => {
        router.pushUrl({
          url: 'pages/AVCastPicker'
        })
      })
    AVSessionClass.currentSession.activate()
  }
}