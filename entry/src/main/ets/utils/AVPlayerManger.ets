import media from '@ohos.multimedia.media'
import { PlayStateType, songItemType } from '../models'
import { SONG_KEY } from '../constants'
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
      }
    })
    //  监听歌曲时长
    AVPlayerManger.player.on('durationUpdate', (duration) => {
      // 每次切换歌曲都会触发这个函数，更新即可
      AVPlayerManger.currentSong.duration = duration
    })
    //  监听播放时长
    AVPlayerManger.player.on('timeUpdate', (time) => {
      AVPlayerManger.currentSong.time = time
      AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManger.currentSong) // 更新全局状态
    })
  }
  // 单首歌播放
  static singlePlay(song: songItemType) {
    // 添加到播放列表中，再进行播放
    const isList = AVPlayerManger.currentSong.playList.some((item: songItemType) => item.id === song.id)
    if (isList) {
      // 是不是正在播放的
      if (AVPlayerManger.player!.url === song.url) {
        // 重新播放（切换当前播放索引的歌曲）
        AVPlayerManger.changePlay()
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

  }
  // 暂停播放
  static pause(){
    AVPlayerManger.player!.pause()
    // 更新播放器状态
    AVPlayerManger.currentSong.isPlay = false
  }
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
}
export default AVPlayerManger