import { requireNativeModule } from 'expo-modules-core';

interface PomeloApplePayCardProvisioningModule {
  isPassKitAvailable(): boolean;
  startEnrollment(
    cardHolderName: string,
    cardId: string,
    cardPanTokenSuffix: string
  ): Promise<{ success: boolean }>;
}

export default requireNativeModule<PomeloApplePayCardProvisioningModule>(
  'PomeloApplePayCardProvisioning'
);
