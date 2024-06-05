import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SONG_KEY } from '../constants';
import AvPlayerManager from '../utils/AvPlayerManger';
import AvSessionManager from '../utils/AvSessionManager';
import FormIdManager from '../utils/FormIdManager';
import { rpc } from '@kit.IPCKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import SongManager from '../utils/SongManager';

//引入rpc实现其类型
class Params implements rpc.Parcelable {
  marshalling(messageSequence: rpc.MessageSequence): boolean {
    return true;
  }

  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    return true;
  }
}

class ParamsForm {
  formId: string = ''
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    AvPlayerManager.init() //直接初始化播放器
    AvSessionManager.init(this.context)


    //监听formId
    this.callee.on('getFormId', data => {
      const res = JSON.parse(data.readString()) as ParamsForm
      // formProvider.updateForm(res.formId, formBindingData.createFormBindingData({
      //   song: AppStorage.get(SONG_KEY)
      // }))
      FormIdManager.addFormId(res.formId)
        .then(() => {
          AvPlayerManager.pushImg() //硬推一次
        })
      return new Params() //为了不报错
    })
    //上一首
    this.callee.on('prev', () => {
      AvPlayerManager.prevPlay()
      return new Params()
    })
    //下一首
    this.callee.on('next', () => {
      AvPlayerManager.prevPlay()
      return new Params()
    })
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {

    const win = await windowStage.getMainWindow()
    win.setWindowLayoutFullScreen(true)
    AppStorage.setOrCreate("topHeight", px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      .topRect.height))
    AppStorage.setOrCreate("bottomHeight", px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      .bottomRect.height))
    const childWin = await windowStage.createSubWindow("ad_win") // 创建广告子窗口
    await childWin.showWindow()
    await childWin.setUIContent("pages/Start/Start")
    // AvPlayerManager.init() //初始化播放器
    // AvSessionManager.init(this.context) // 初始化媒体会话
    FormIdManager.context = this.context //赋值上下文
    SongManager.context = this.context //这里容易漏下来 漏下来Index就是白的
    const currentSong = await SongManager.getSong() //给播放器
    currentSong.isPlay = false //无论什么情况 肯定是关着的
    AvPlayerManager.currentSong = currentSong
    if (AvPlayerManager.currentSong.url) {
      AvPlayerManager.player!.url = AvPlayerManager.currentSong.url //会自动播放
      AppStorage.setOrCreate('firstplay', 1) //首次播放
    }
    AppStorage.setOrCreate(SONG_KEY, AvPlayerManager.currentSong) //更新全局状态
    windowStage.loadContent("pages/Index/Index")
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
