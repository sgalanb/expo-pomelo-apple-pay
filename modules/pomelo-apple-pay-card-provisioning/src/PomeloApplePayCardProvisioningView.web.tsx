import * as React from 'react';

import { PomeloApplePayCardProvisioningViewProps } from './PomeloApplePayCardProvisioning.types';

export default function PomeloApplePayCardProvisioningView(props: PomeloApplePayCardProvisioningViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
