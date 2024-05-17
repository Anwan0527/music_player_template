import media from '@ohos.multimedia.media'
import { PlayStateType, songItemType } from '../models'
import { SONG_KEY } from '../constants'
import { router } from '@kit.ArkUI'
import { wantAgent } from '@kit.AbilityKit'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import AvSessionManager from './AvSessionManager'
import { formBindingData, formProvider } from '@kit.FormKit'
import FormIdManager from './FormIdManager'

class AVPlayerManger {
  // 创建的播放器应该存在我们的工具类上，这样才能被导出使用
  static player: media.AVPlayer | null = null
  static currentSong: PlayStateType = new PlayStateType() // 当前歌曲的状态

  // 创建播放器的方法
  static async init() {
    if (!AVPlayerManger.player) {
      AVPlayerManger.player = await media.createAVPlayer()
    }
    // 监听状态
    AVPlayerManger.player.on('stateChange', (state) => {
      switch (state) {
      // 初始化
        case 'initialized':
          AVPlayerManger.player!.prepare()
          break
      // 准备
        case 'prepared':
          AVPlayerManger.player!.play()
          AVPlayerManger.currentSong.isPlay = true // 播放状态
          break
        case "completed":
          AVPlayerManger.nextPlay(AVPlayerManger.currentSong.playMode === "repeat")
          break
      }
    })
    //  监听歌曲时长
    AVPlayerManger.player.on('durationUpdate', (duration) => {
      // 每次切换歌曲都会触发这个函数，更新即可
      AVPlayerManger.currentSong.duration = duration
      AvSessionManager.setAvMetaData(AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex])
    })
    let timer: number | null = null
    //  监听播放时长
    AVPlayerManger.player.on('timeUpdate', async (time) => {
      AVPlayerManger.currentSong.time = time
      AvSessionManager.setAVPlaybackState() // 更新状态
      AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManger.currentSong) // 更新全局状态
      // 防抖

      if (!timer) {
        timer = setTimeout(async () => {
          const formIdList = FormIdManager.getFormIdList()
          const data = formBindingData.createFormBindingData({
            song: AVPlayerManger.currentSong
          })
          let index = 0
          while (index < formIdList.length) {
            await formProvider.updateForm(formIdList[index], data) // 更新数据
            index++
          }
          timer = null
        }, 1000)
      }

    })
  }

  // 单首歌播放
  static async singlePlay(song: songItemType) {
    AVPlayerManger.startBackgroundTask()
    // 添加到播放列表中，再进行播放
    const isList = AVPlayerManger.currentSong.playList.some((item: songItemType) => item.id === song.id)
    if (isList) {
      // 是不是正在播放的
      if (AVPlayerManger.player!.url === song.url) {
        // 重新播放（切换当前播放索引的歌曲）
        AVPlayerManger.player?.play()
        AVPlayerManger.currentSong.isPlay = true
      } else {
        // 切换歌曲(更新播放索引切换歌曲)
        AVPlayerManger.currentSong.playIndex =
          AVPlayerManger.currentSong.playList.findIndex((item: songItemType) => item.id === song.id)
        AVPlayerManger.changePlay()
      }
    } else {
      AVPlayerManger.currentSong.playList.unshift(song)
      AVPlayerManger.currentSong.playIndex = 0
      AVPlayerManger.changePlay()
    }
    AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManger.currentSong) // 更新全局状态
    AvSessionManager.setAVPlaybackState() // 更新状态


  }

  // 暂停播放
  static pause() {
    AVPlayerManger.player!.pause()
    // 更新播放器状态
    AVPlayerManger.currentSong.isPlay = false
    AvSessionManager.setAVPlaybackState() // 更新状态
  }

  // 上一首
  static prevPlay() {
    // 如果是随机播放
    if (AVPlayerManger.currentSong.playMode === "random" && AVPlayerManger.currentSong.playList.length) {
      let index = -1
      do {
        index = Math.floor(Math.random() * AVPlayerManger.currentSong.playList.length)
      } while (index === AVPlayerManger.currentSong.playIndex)
      AVPlayerManger.currentSong.playIndex = index
    } else {
      AVPlayerManger.currentSong.playIndex--
      // 有可能减到负数
      AVPlayerManger.currentSong.playIndex =
        (AVPlayerManger.currentSong.playIndex + AVPlayerManger.currentSong.playList.length) %
        AVPlayerManger.currentSong.playList.length
    }
    AVPlayerManger.singlePlay(AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex])
  }

  // 下一首
  static nextPlay(repeat?: boolean) {
    if (!AVPlayerManger.currentSong.playList.length) {
      return
    }
    if (!repeat) {
      if (AVPlayerManger.currentSong.playMode === "random" && AVPlayerManger.currentSong.playList.length) {
        let index = 0
        do {
          index = Math.floor(Math.random() * AVPlayerManger.currentSong.playList.length)
        } while (index === AVPlayerManger.currentSong.playIndex)
        AVPlayerManger.currentSong.playIndex = index

      } else {
        AVPlayerManger.currentSong.playIndex++
        // 有可能减到负数
        AVPlayerManger.currentSong.playIndex =
          (AVPlayerManger.currentSong.playIndex + AVPlayerManger.currentSong.playList.length) %
          AVPlayerManger.currentSong.playList.length
      }
    }

    AVPlayerManger.singlePlay(AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex])
  }

  // 下一首
  // 切换歌曲
  static async changePlay() {
    // 重置播放器状态至初始化,异步方法
    await AVPlayerManger.player!.reset()
    // 重置播放状态
    AVPlayerManger.currentSong.duration = 0
    AVPlayerManger.currentSong.time = 0
    AVPlayerManger.player!.url = AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex].url
    AVPlayerManger.currentSong.img = AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex].img
    AVPlayerManger.currentSong.name = AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex].name
    AVPlayerManger.currentSong.author = AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex].author
    AVPlayerManger.currentSong.url = AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex].url
  }

  // 删除播放
  static async remove(index: number) {
    if (AVPlayerManger.currentSong.playIndex === index) {
      // 是否删除正在播放的歌曲
      if (AVPlayerManger.currentSong.playList.length > 1) {
        // 如果当前的歌曲列表超过两个
        AVPlayerManger.currentSong.playList.splice(index, 1)
        AVPlayerManger.currentSong.playIndex =
          (AVPlayerManger.currentSong.playIndex + AVPlayerManger.currentSong.playList.length) %
          AVPlayerManger.currentSong.playList.length
        AVPlayerManger.singlePlay(AVPlayerManger.currentSong.playList[AVPlayerManger.currentSong.playIndex])
      } else {
        await AVPlayerManger.player!.reset()
        AVPlayerManger.currentSong = new PlayStateType() // 重置数据
        router.back()
      }

    } else {
      // 如果不是
      if (AVPlayerManger.currentSong.playIndex > index) {
        AVPlayerManger.currentSong.playIndex--
      }
      AVPlayerManger.currentSong.playList.splice(index, 1)
    }
    AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManger.currentSong) // 更新全局状态
  }

  // 开启后台任务
  static async startBackgroundTask() {
    if (AvSessionManager.session.sessionId) {
      // 如果有会话id 则不用开启后台任务
      return
    }
    try {
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
      const want = await wantAgent.getWantAgent(wantAgentInfo) // 获取want信息
      await backgroundTaskManager.startBackgroundRunning(getContext(),
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
        want)
    } catch (error) {
      // 错误消息
      AlertDialog.show({ message: error.message })
    }

  }
}

export default AVPlayerManger