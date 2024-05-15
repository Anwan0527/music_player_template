import media from '@ohos.multimedia.media'
import { PlayStateType, songItemType } from '../models'
import { SONG_KEY } from '../constants'

export class AVPlayerClass {
  // 创建的播放器应该存在我们的工具类上，这样才能被导出使用
  static player: media.AVPlayer | null = null
  static currentSong: PlayStateType = new PlayStateType() // 当前歌曲的状态
  // 创建播放器的方法
  static async init() {
    if (!AVPlayerClass.player) {
      AVPlayerClass.player = await media.createAVPlayer()
    }
    // 监听状态
    AVPlayerClass.player.on('stateChange', (state) => {
      switch (state) {
      // 初始化
        case 'initialized':
          AVPlayerClass.player!.prepare()
          break
      // 准备
        case 'prepared':
          AVPlayerClass.player!.play()
          AVPlayerClass.currentSong.isPlay = true // 播放状态
          break
      }
    })
    //  监听歌曲时长
    AVPlayerClass.player.on('durationUpdate', (duration) => {
      // 每次切换歌曲都会触发这个函数，更新即可
      AVPlayerClass.currentSong.duration = duration
    })
    //  监听播放时长
    AVPlayerClass.player.on('timeUpdate', (time) => {
      AVPlayerClass.currentSong.time = time
      AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerClass.currentSong) // 更新全局状态
    })
  }

  // 单首歌播放
  static singlePlay(song: songItemType) {
    // 添加到播放列表中，再进行播放
    const isList = AVPlayerClass.currentSong.playList.some((item: songItemType) => item.id === song.id)
    if (isList) {
      // 是不是正在播放的
      if (AVPlayerClass.player!.url === song.url) {
        // 重新播放（切换当前播放索引的歌曲）
        AVPlayerClass.changePlay()
      } else {
        // 切换歌曲(更新播放索引切换歌曲)
        AVPlayerClass.currentSong.playIndex =
          AVPlayerClass.currentSong.playList.findIndex((item: songItemType) => item.id === song.id)
        AVPlayerClass.changePlay()
      }
    } else {
      AVPlayerClass.currentSong.playList.unshift(song)
      AVPlayerClass.currentSong.playIndex = 0
      AVPlayerClass.changePlay()
    }

  }

  // 切换歌曲
  static async changePlay() {
    // 重置播放器状态至初始化,异步方法
    await AVPlayerClass.player!.reset()
    // 重置播放状态
    AVPlayerClass.currentSong.duration = 0
    AVPlayerClass.currentSong.time = 0
    AVPlayerClass.player!.url = AVPlayerClass.currentSong.playList[AVPlayerClass.currentSong.playIndex].url
    AVPlayerClass.currentSong.img = AVPlayerClass.currentSong.playList[AVPlayerClass.currentSong.playIndex].img
    AVPlayerClass.currentSong.name = AVPlayerClass.currentSong.playList[AVPlayerClass.currentSong.playIndex].name
    AVPlayerClass.currentSong.author = AVPlayerClass.currentSong.playList[AVPlayerClass.currentSong.playIndex].author
    AVPlayerClass.currentSong.url = AVPlayerClass.currentSong.playList[AVPlayerClass.currentSong.playIndex].url
  }
}