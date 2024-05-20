// 传输数据的结构
import { songItemType } from './music';

export class PlayStateType {
  img: string = "" // 音乐封面
  name: string = "" // 音乐名称
  author: string = "" // 作者
  url: string = "" // 当前播放连接
  playIndex: number =  0 // 当前在播放列表中的播放索引
  time: number = 0 // 播放时间
  duration: number = 0 // 音乐的播放市场
  isPlay: boolean = false // 是否正在播放
  playMode: 'auto' | 'repeat' | 'random' = "auto" // 播放模式
  playList: songItemType[] = [] // 当前的播放列表
  cacheImg?: string // 缓存图片地址
}

