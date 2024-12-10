import ExpoModulesCore
import PassKit

public class PomeloApplePayCardProvisioningModule: Module {
    private var delegate: CardProvisioningDelegate?
    
    public func definition() -> ModuleDefinition {
        Name("PomeloApplePayCardProvisioning")

        // Adds the ability to send a console log message from native to RN
        Events("consoleLog")

        Function("isPassKitAvailable") {
            return PKAddPaymentPassViewController.canAddPaymentPass()
        }
        
        AsyncFunction("startEnrollment") { (cardHolderName: String, cardId: String, cardPanTokenSuffix: String, promise: Promise) in
            // Example consoleLog
            self.sendEvent("consoleLog", ["message": "Starting enrollment for card: \(cardId)"])
            
            guard PKAddPaymentPassViewController.canAddPaymentPass() else {
                promise.reject("ERROR", "Apple Pay no está disponible para tu dispositivo.")
                return
            }
            
            let card = Card(panTokenSuffix: cardPanTokenSuffix, holder: cardHolderName)
            
            guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
                promise.reject("ERROR", "Apple Pay no está disponible para tu dispositivo por el momento.")
                return
            }
            
            configuration.cardholderName = card.holder
            configuration.primaryAccountSuffix = card.panTokenSuffix
            
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                promise.reject("ERROR", "No se pudo encontrar el view controller.")
                return
            }
            
            delegate = CardProvisioningDelegate(promise: promise)
            
            guard let enrollViewController = PKAddPaymentPassViewController(
                requestConfiguration: configuration,
                delegate: delegate
            ) else {
                promise.reject("ERROR", "Apple Pay no está disponible para tu dispositivo. Ocurrió un error al configurarlo")
                return
            }
            
            DispatchQueue.main.async {
                rootViewController.present(enrollViewController, animated: true)
            }
        }
    }
}

private class CardProvisioningDelegate: NSObject, PKAddPaymentPassViewControllerDelegate {
    private let promise: Promise
    
    init(promise: Promise) {
        self.promise = promise
        super.init()
    }
    
    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        generateRequestWithCertificateChain certificates: [Data],
        nonce: Data,
        nonceSignature: Data,
        completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
    ) {
        let request = IssuerRequest(
            certificates: certificates,
            nonce: nonce,
            nonceSignature: nonceSignature,
            cardId: "crd-1234567890"
        )
        
        let interactor = GetPassKitDataIssuerHostInteractor()
        interactor.execute(request: request, promise: promise) { response in
            let request = PKAddPaymentPassRequest()
            request.activationData = response.activationData
            request.ephemeralPublicKey = response.ephemeralPublicKey
            request.encryptedPassData = response.encryptedPassData
            handler(request)
        }
    }
    
    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        didFinishAdding pass: PKPaymentPass?,
        error: Error?
    ) {
        controller.dismiss(animated: true) {
            if let _ = pass {
                self.promise.resolve(["success": true])
            } else {
                self.promise.resolve(["success": false])
            }
        }
    }
}

// Helper types remain the same
private struct Card {
    let panTokenSuffix: String
    let holder: String
}

private struct IssuerRequest {
    let certificates: [Data]
    let nonce: Data
    let nonceSignature: Data
    let cardId: String
}

private struct IssuerResponse {
    let activationData: Data
    let ephemeralPublicKey: Data
    let encryptedPassData: Data
}

private class GetPassKitDataIssuerHostInteractor {
    private let baseURL = "https://api.pomelo.la" // Replace with actual base URL
    
    func execute(request: IssuerRequest, promise: Promise, onFinish: @escaping (IssuerResponse) -> Void) {
        // Prepare URL
        guard let url = URL(string: "\(baseURL)/token-provisioning/mastercard/apple-pay") else {
            print("Invalid URL")
            return
        }
        
        // Convert binary data to base64 strings
        let certificatesBase64 = request.certificates.map { $0.base64EncodedString() }
        let nonceBase64 = request.nonce.base64EncodedString()
        let nonceSignatureBase64 = request.nonceSignature.base64EncodedString()
        
        // Prepare request body
        let body: [String: Any] = [
            "card_id": request.cardId,
            "certificates": certificatesBase64,
            "nonce": nonceBase64,
            "nonce_signature": nonceSignatureBase64,
            "user_id": "usr-20gRqyp8095vDzXzhSeG2w6UiO5" // Hardcoded for now
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                promise.reject("ERROR", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                promise.reject("ERROR", "No data received from Pomelo API.")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let responseData = json["data"] as? [String: Any],
                      let activationDataString = responseData["activation_data"] as? String,
                      let encryptedPassDataString = responseData["encrypted_pass_data"] as? String,
                      let ephemeralPublicKeyString = responseData["ephemeral_public_key"] as? String,
                      let activationData = Data(base64Encoded: activationDataString),
                      let encryptedPassData = Data(base64Encoded: encryptedPassDataString),
                      let ephemeralPublicKey = Data(base64Encoded: ephemeralPublicKeyString) else {
                    promise.reject("ERROR", "Invalid response format.")
                    return
                }
                
                let response = IssuerResponse(
                    activationData: activationData,
                    ephemeralPublicKey: ephemeralPublicKey,
                    encryptedPassData: encryptedPassData
                )
                
                DispatchQueue.main.async {
                    onFinish(response)
                }
            } catch {
                promise.reject("ERROR", error.localizedDescription)
            }
        }
        
        task.resume()
    }
}
