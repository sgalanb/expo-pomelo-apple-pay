
import PomeloApplePayCardProvisioning, { OnErrorMessageEventPayload, PomeloApplePayCardProvisioningView } from "@/modules/pomelo-apple-pay-card-provisioning";
import { requireNativeModule } from "expo";
import { useState } from "react";
import { Text, View } from "react-native";

export default function Index() {

  const isPassKitAvailable = PomeloApplePayCardProvisioning.isPassKitAvailable();
  console.log("isPassKitAvailable", isPassKitAvailable);

  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  PomeloApplePayCardProvisioning.addListener('onErrorMessage', (event: OnErrorMessageEventPayload) => {
    console.log("onErrorMessage", event);
  });

  return (
    <View
      style={{
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <Text>Hello</Text>
      <View style={{
        margin: 20,
        backgroundColor: '#fff',
        borderRadius: 10,
        padding: 20,
      }}>
      <Text style={{
        fontSize: 20,
        marginBottom: 20,
      }}>Pomelo Apple Pay Card Provisioning</Text>
      <PomeloApplePayCardProvisioningView
        cardHolderName="John Doe"
        cardId="1234567890"
        cardPanTokenSuffix="1234"
        style={{
          height: 200,
        }}
      />
    </View>
    </View>
  );
}
