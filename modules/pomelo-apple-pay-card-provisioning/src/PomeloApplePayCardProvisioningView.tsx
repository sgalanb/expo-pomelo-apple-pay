import { requireNativeView } from 'expo';
import * as React from 'react';

import { PomeloApplePayCardProvisioningViewProps } from './PomeloApplePayCardProvisioning.types';

const NativeView: React.ComponentType<PomeloApplePayCardProvisioningViewProps> =
  requireNativeView('PomeloApplePayCardProvisioning');

export default function PomeloApplePayCardProvisioningView(props: PomeloApplePayCardProvisioningViewProps) {
  return <NativeView {...props} />;
}
