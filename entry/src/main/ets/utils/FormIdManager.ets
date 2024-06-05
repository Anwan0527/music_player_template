import { Context } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'

export default class FormIdManager {
  static context: Context

  // 获取store
  static getStore() {
    return preferences.getPreferencesSync(FormIdManager.context || getContext(), {
      name: 'music_formId'
    })
  }

  //储存卡片Id
  static async addFormId(formId: string) {
    const store = FormIdManager.getStore()
    const list = FormIdManager.getFormIdList()
    if (!list.some(id => id === formId)) {
      list.push(formId)
    }
    store.putSync('music_formId_key', JSON.stringify(list))
    await store.flush()
  }

  //获取卡片Id数组
  static getFormIdList() {
    const store = FormIdManager.getStore()
    return JSON.parse(store.getSync('music_formId_key', '[]') as string) as string[]
  }

  //删除
  static async delFormId(formId: string) {
    const store = FormIdManager.getStore()
    const list = FormIdManager.getFormIdList()
    const index = list.findIndex(id => id === formId)
    list.splice(index, 1)
    store.putSync('music_formId_key', JSON.stringify(list))
    await store.flush()
  }
}