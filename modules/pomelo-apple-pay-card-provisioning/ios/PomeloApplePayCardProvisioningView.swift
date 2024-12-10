import ExpoModulesCore
import PassKit

class PomeloApplePayCardProvisioningView: ExpoView {
    let onLoad = EventDispatcher()
    private var infoLabel: UILabel!
    
    var cardHolderName: String {
        didSet {
            print("[PomeloApplePayCardProvisioning] cardHolderName changed to: \(cardHolderName)")
            updateLabel()
        }
    }
    var cardId: String {
        didSet {
            print("[PomeloApplePayCardProvisioning] cardId changed to: \(cardId)")
            updateLabel()
        }
    }
    var cardPanTokenSuffix: String {
        didSet {
            print("[PomeloApplePayCardProvisioning] cardPanTokenSuffix changed to: \(cardPanTokenSuffix)")
            updateLabel()
        }
    }
    
    required init(appContext: AppContext? = nil) {
        self.cardHolderName = ""
        self.cardId = ""
        self.cardPanTokenSuffix = ""
        super.init(appContext: appContext)
        print("[PomeloApplePayCardProvisioning] View initialized with empty values")
        clipsToBounds = true
        setupApplePayButton()
    }
    
    private func setupApplePayButton() {
        let passKitButton = PKAddPassButton(addPassButtonStyle: .blackOutline)
        passKitButton.addTarget(self, action: #selector(onEnroll), for: .touchUpInside)
        addSubview(passKitButton)
        passKitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passKitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            passKitButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            passKitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            passKitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            passKitButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        infoLabel = UILabel()
        infoLabel.textColor = .black
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: passKitButton.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        updateLabel()
    }

    private func updateLabel() {
        infoLabel?.text = """
            Card Holder: \(cardHolderName)
            Card ID: \(cardId)
            Card Suffix: \(cardPanTokenSuffix)
            """
    }
    
    @objc private func onEnroll(button: UIButton) {
        guard isPassKitAvailable() else {
            showPassKitUnavailable(message: "Apple Pay no está disponible para tu dispositivo")
            return
        }
        
        initEnrollProcess()
    }
    
    private func initEnrollProcess() {
        let card = cardInformation()

        print("[PomeloApplePayCardProvisioning] card: \(card)")
        
        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
            showPassKitUnavailable(
                message: "Apple Pay no está disponible para tu dispositivo por el momento")
            return
        }
        
        configuration.cardholderName = card.holder
        configuration.primaryAccountSuffix = card.panTokenSuffix
        
        guard
            let enrollViewController = PKAddPaymentPassViewController(
                requestConfiguration: configuration, delegate: self)
        else {
            onErrorMessage(["message": "Apple Pay no está disponible para tu dispositivo. Ocurrió un error al configurarlo"])
            showPassKitUnavailable(
                message: "Apple Pay no está disponible para tu dispositivo. Ocurrió un error al configurarlo")
            return
        }
        
        // Get the closest view controller to present the enrollment view
        if let viewController = findViewController() {
            viewController.present(enrollViewController, animated: true, completion: nil)
        }
    }

    @objc
    private func errorMessageListener() {
        sendEvent("onErrorMessage", [
            "message": "Apple Pay no está disponible para tu dispositivo. Ocurrió un error al configurarlo"
        ])
    }
    
    private func showPassKitUnavailable(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        if let viewController = findViewController() {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

// MARK: - PKAddPaymentPassViewControllerDelegate
extension PomeloApplePayCardProvisioningView: PKAddPaymentPassViewControllerDelegate {
    func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController,
                                    generateRequestWithCertificateChain certificates: [Data],
                                    nonce: Data,
                                    nonceSignature: Data,
                                    completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
        
        let request = IssuerRequest(
            certificates: certificates, nonce: nonce, nonceSignature: nonceSignature,
            cardId: "crd-1234567890")
        
        let interactor = GetPassKitDataIssuerHostInteractor()
        interactor.execute(request: request) { response in
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
        if let _ = pass {
            print("Se pudo agregar la tarjeta a Apple Pay")
            onLoad(["success": true])
        } else {
            print("Ocurrió un error y no se pudo agregar la tarjeta a Apple Pay")
            onLoad(["success": false])
        }
    }
}

// MARK: - Helper Functions and Types
private func isPassKitAvailable() -> Bool {
    return PKAddPaymentPassViewController.canAddPaymentPass()
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
    func execute(request: IssuerRequest, onFinish: (IssuerResponse) -> Void) {
        let response = IssuerResponse(
            activationData: Data(),
            ephemeralPublicKey: Data(),
            encryptedPassData: Data())
        onFinish(response)
    }
}

private struct Card {
    let panTokenSuffix: String
    let holder: String
}

private func cardInformation() -> Card {
    return Card(panTokenSuffix: "4321", holder: "John Doe")
}