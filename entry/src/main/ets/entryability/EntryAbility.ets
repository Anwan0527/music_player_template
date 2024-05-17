import { abilityAccessCtrl, AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import AVPlayerManger from '../utils/AVPlayerManger';
import AvSessionManager from '../utils/AvSessionManager';
import FormIdManager from '../utils/FormIdManager';
import rpc from '@ohos.rpc';
import { formBindingData, formProvider } from '@kit.FormKit';
import { SONG_KEY } from '../constants';

class Params implements rpc.Parcelable {
  marshalling(messageSequence: rpc.MessageSequence): boolean {
    return true;
  }

  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    return true;
  }
}

class ParamsForm {
  formId: string = ""
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 上一首
    this.callee.on("prev", () => {
      AVPlayerManger.prevPlay()
      return new Params();
    })
    // 下一首
    this.callee.on("next", () => {
      AVPlayerManger.nextPlay()
      return new Params();
    })
    // 下一首
    // 监听formId
    this.callee.on("getFormId", (data) => {
      const res = JSON.parse(data.readString()) as ParamsForm
      formProvider.updateForm(res.formId, formBindingData.createFormBindingData({
        song: AppStorage.get(SONG_KEY)
      }))
      FormIdManager.addFormId(res.formId)
      return new Params();
    })
  }

  onDestroy(): void {
    this.callee.off("prev")
    this.callee.off("next")
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
    AVPlayerManger.init()
    AvSessionManager.init(this.context) //初始化媒体会话
    FormIdManager.context = this.context // 赋值上下文
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
