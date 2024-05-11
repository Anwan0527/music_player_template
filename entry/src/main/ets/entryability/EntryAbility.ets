import { abilityAccessCtrl,AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import AVPlayerClass from '../utils/AVPlayerClass';
import AVSessionClass from '../utils/AVSessionClass';
import AudioCapturer from '../utils/AudioCapturer';
import AudioRender from '../utils/AudioRender';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.context, [
      "ohos.permission.MICROPHONE"
    ]).then(()=> {
      AVPlayerClass.init(this.context)
      AVSessionClass.init(this.context)
      AudioCapturer.init()
      AudioRender.init()
      windowStage.getMainWindow().then(window => {
        window.setWindowLayoutFullScreen(true)
      })
      windowStage.loadContent('pages/Start');
    })
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
    // Ability has back to background
    AudioCapturer.stop()
    AudioRender.stop()
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
