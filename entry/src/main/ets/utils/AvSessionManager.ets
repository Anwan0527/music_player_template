import AvSession from '@ohos.multimedia.avsession'

export default class AvSessionManager {
  static session: AvSession.AVSession
  static controller: AvSession.AVSessionController
  // 初始化媒体会话
  static async init(context: Context) {
    AvSessionManager.session = await AvSession.createAVSession(context, 'bgPlay', 'audio') // 拿到会话对象
    AvSessionManager.controller = await AvSessionManager.session.getController() // 拿到会话控制器
  }
}