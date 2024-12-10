import { ConsoleLogEvent } from '@/modules/pomelo-apple-pay-card-provisioning/src/PomeloApplePayCardProvisioning.types';
import { requireNativeModule } from 'expo-modules-core';

interface PomeloApplePayCardProvisioningModule {
  isPassKitAvailable(): boolean;
  startEnrollment(
    cardHolderName: string,
    cardId: string,
    cardPanTokenSuffix: string
  ): Promise<{ success: boolean }>;
  addListener(event: string, listener: (event: ConsoleLogEvent) => void): void;
}

export default requireNativeModule<PomeloApplePayCardProvisioningModule>(
  'PomeloApplePayCardProvisioning'
);
