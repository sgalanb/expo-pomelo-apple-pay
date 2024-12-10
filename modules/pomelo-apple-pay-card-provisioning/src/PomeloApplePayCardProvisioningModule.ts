import { NativeModule, requireNativeModule } from 'expo';

import { PomeloApplePayCardProvisioningModuleEvents } from './PomeloApplePayCardProvisioning.types';

declare class PomeloApplePayCardProvisioningModule extends NativeModule<PomeloApplePayCardProvisioningModuleEvents> {
    isPassKitAvailable(): boolean;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<PomeloApplePayCardProvisioningModule>('PomeloApplePayCardProvisioning');
