import { requireNativeModule } from 'expo-modules-core';

// The simplest possible module definition - just to enable the native view
export interface PomeloApplePayModule {}

export default requireNativeModule<PomeloApplePayModule>('PomeloApplePay');
