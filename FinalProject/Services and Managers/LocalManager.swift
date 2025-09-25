import SwiftUI
import Combine

final class LocaleManager: ObservableObject {
    @Published var locale: Locale = .current
    
    func setLanguage(_ identifier: String) {
        locale = Locale(identifier: identifier)
        UserDefaults.standard.set(identifier, forKey: "AppLanguage")
    }
    
    init() {
        if let savedLang = UserDefaults.standard.string(forKey: "AppLanguage") {
            locale = Locale(identifier: savedLang)
        }
    }
}
