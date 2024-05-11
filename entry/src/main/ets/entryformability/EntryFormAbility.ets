import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { PreferencesClass } from '../utils/PreferencesClass';
import { SubscriberClass } from '../utils/SubscriberClasss';
import { PublishEventType } from '../constants/EventContants';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    let formData = '';
    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string
    SubscriberClass.publish(PublishEventType.CARD_PUBLISH,formId)
    const preferences = new PreferencesClass(this.context)
    preferences.setFormId(formId)
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onChangeFormVisibility(newStatus: Record<string, number>) {
    // Called when the form provider receives form events from the system.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
    SubscriberClass.publish(PublishEventType.CARD_PUBLISH,JSON.parse(message).type)
  }

  onRemoveForm(formId: string) {
    SubscriberClass.publish(PublishEventType.CARD_PUBLISH,'')
    const preferences = new PreferencesClass(this.context)
    preferences.setFormId('')
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};