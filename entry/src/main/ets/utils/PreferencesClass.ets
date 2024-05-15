import preferences from '@ohos.data.preferences'
import { PlayStateType } from '../models/playState'

export class PreferencesClass {
  StoreName = 'HEIMA_CLOUD_MUSIC'
  PlayStateKey = 'HEIMA_PLAY_STATE'
  FormIdKey = 'HEIMA_FORM_ID'
  context: Context

  constructor(context: Context) {
    this.context = context
  }
  // 获取store
  getStore() {
    return preferences.getPreferencesSync(this.context,{name:this.StoreName})
  }
  // 存储播放状态
  async setPlayState(playState:PlayStateType){
    const store = this.getStore()
    store.putSync(this.PlayStateKey,JSON.stringify(playState))
    await store.flush()
  }
  // 获取播放状态
  getPlayState(){
    const store = this.getStore()
    return JSON.parse(store.getSync(this.PlayStateKey,JSON.stringify("{}")) as string) as PlayStateType
  }
  // 存储卡片ID
  async setFormId(id:string){
    const store = this.getStore()
    store.putSync(this.FormIdKey,id)
    await store.flush()
  }
  // 获取卡片ID
  getFormId(){
    const store = this.getStore()
    return store.getSync(this.FormIdKey,'') as string
  }
}