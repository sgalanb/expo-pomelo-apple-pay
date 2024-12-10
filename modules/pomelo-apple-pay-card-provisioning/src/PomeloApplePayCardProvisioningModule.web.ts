import { registerWebModule, NativeModule } from 'expo';

import { ChangeEventPayload } from './PomeloApplePayCardProvisioning.types';

type PomeloApplePayCardProvisioningModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
}

class PomeloApplePayCardProvisioningModule extends NativeModule<PomeloApplePayCardProvisioningModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
};

export default registerWebModule(PomeloApplePayCardProvisioningModule);
