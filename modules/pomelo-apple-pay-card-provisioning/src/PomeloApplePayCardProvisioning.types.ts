import type { StyleProp, ViewStyle } from 'react-native';

export type OnLoadEventPayload = {
  url: string;
};

export type PomeloApplePayCardProvisioningModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
  onErrorMessage: (params: OnErrorMessageEventPayload) => void;
};

export type ChangeEventPayload = {
  value: string;
};

export type OnErrorMessageEventPayload = {
  message: string;
};

export type PomeloApplePayCardProvisioningViewProps = {
  cardHolderName: string;
  cardId: string;
  cardPanTokenSuffix: string;
  style?: StyleProp<ViewStyle>;
};
