//持久化播放列表
import { preferences } from '@kit.ArkData'
import { PlayStateType } from '../models'

export default class SongManager {
  static context: Context

  //获取store
  // 获取store
  static getStore() {
    return preferences.getPreferencesSync(SongManager.context || getContext(), {
      name: 'song_cache'
    })
  }

  //更新音乐
  static async updateSong(song: string) {
    const store = SongManager.getStore()
    store.putSync('song_cache_key', song)
    await store.flush()
  }

  static async getSong() {
    const store = SongManager.getStore()
    return JSON.parse(store.getSync('song_cache_key', JSON.stringify(new PlayStateType())) as string) as PlayStateType
  }
}