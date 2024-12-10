
import PomeloApplePayCardProvisioning from "@/modules/pomelo-apple-pay-card-provisioning";
import { Alert, Pressable, Text, View } from "react-native";
import { Image } from "expo-image";
import { ConsoleLogEvent } from "@/modules/pomelo-apple-pay-card-provisioning/src/PomeloApplePayCardProvisioning.types";

export default function Index() {

  PomeloApplePayCardProvisioning.addListener('consoleLog', (event: ConsoleLogEvent) => {
    console.log(event.message);
  });

  const addToAppleWallet = async () => {
    try {
      if (!PomeloApplePayCardProvisioning.isPassKitAvailable()) {
        Alert.alert('Error', 'Apple Pay is not available on this device');
        return;
      }
  
      const result = await PomeloApplePayCardProvisioning.startEnrollment(
        'John Doe',
        'card-123',
        '4321'
      );
  
      if (result.success) {
        console.log('Card added successfully');
      } else {
        console.log('Failed to add card');
      }
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <View
      style={{
        flex: 1,
        width: '100%',
        justifyContent: "center",
        alignItems: "center",
        padding: 20,
      }}
    >
      <View style={{
        margin: 20,
        width: '100%',
        backgroundColor: '#fff',
        borderRadius: 10,
        padding: 20,
        justifyContent: 'center',
        alignItems: 'center',
      }}>
      <Text style={{
        fontSize: 20,
        marginBottom: 20,
      }}>Pomelo Apple Pay Card Provisioning</Text>
      <Pressable
        onPress={addToAppleWallet}
        style={{
          width: '100%',
          flexDirection: 'row',
          gap: 8,
          backgroundColor: '#6d37d5',
          padding: 4,
          borderRadius: 8,
          justifyContent: 'center',
          alignItems: 'center',
          height: 40,
        }}
      >
        <Image source="https://upload.wikimedia.org/wikipedia/commons/b/b2/Apple_Wallet_Icon.svg" style={{
          width: 24,
          aspectRatio: 750 / 563.15
        }} />
        <Text style={{
          color: '#fff',
          fontSize: 14,
        fontWeight: 600,
        }}>Agregar a Apple Wallet</Text>
      </Pressable>
    </View>
    </View>
  );
}
