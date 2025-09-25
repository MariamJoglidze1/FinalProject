import Testing
import Foundation
import Combine
@testable import FinalProject

struct LocaleManagerTests {
    
    @Test
    func testDefaultInitialization() {
        UserDefaults.standard.removeObject(forKey: "AppLanguage")
        
        let manager = LocaleManager()
        #expect(manager.locale.identifier == Locale.current.identifier)
    }
    
    @Test func testInitializationWithSavedLanguage() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "AppLanguage") 
        defaults.set("fr", forKey: "AppLanguage")
        
        let manager = LocaleManager()
        
        #expect(manager.locale.identifier == "fr")
    }

    
    @Test
    func testSetLanguageUpdatesLocale() {
        UserDefaults.standard.removeObject(forKey: "AppLanguage")
        
        let manager = LocaleManager()
        manager.setLanguage("es")
        
        #expect(manager.locale.identifier == "es")
    }
    
    @Test
    func testSetLanguagePersistsToUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "AppLanguage")
        
        let manager = LocaleManager()
        manager.setLanguage("de")
        
        let saved = UserDefaults.standard.string(forKey: "AppLanguage")
        #expect(saved == "de")
    }
    
    @Test func testLocalePublisherEmitsChanges() async throws {
        let manager = LocaleManager()
        var receivedLocales: [Locale] = []
        
        let cancellable = manager.$locale.sink { locale in
            receivedLocales.append(locale)
        }
        
        manager.setLanguage("it")
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(receivedLocales.last?.language.languageCode?.identifier == "it")
        
        cancellable.cancel()
    }
}
