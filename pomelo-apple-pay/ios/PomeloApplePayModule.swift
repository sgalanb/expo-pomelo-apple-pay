import ExpoModulesCore
import PassKit

public class PomeloApplePayModule: Module {
    public func definition() -> ModuleDefinition {
        Name("PomeloApplePay")
        
        // Only define the view component
        View(PomeloApplePayView.self) {}
    }
}
