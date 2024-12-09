// Reexport the native module. On web, it will be resolved to PomeloApplePayModule.web.ts
// and on native platforms to PomeloApplePayModule.ts
export { default } from './PomeloApplePayModule';
export { default as PomeloApplePayView } from './PomeloApplePayView';
export * from  './PomeloApplePay.types';
