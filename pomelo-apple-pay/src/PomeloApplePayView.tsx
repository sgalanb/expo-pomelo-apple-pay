import { requireNativeView } from 'expo';
import * as React from 'react';

import { PomeloApplePayViewProps } from './PomeloApplePay.types';

const NativeView: React.ComponentType<PomeloApplePayViewProps> =
  requireNativeView('PomeloApplePay');

export default function PomeloApplePayView(props: PomeloApplePayViewProps) {
  return <NativeView {...props} />;
}
