import SwiftUI

@Observable
final class FavouritesManager {
    static let shared: FavouritesManager = .init()
    
    private var countries: Set<String>
    private let key = "Favorites"
    private let storage: UserDefaults
    
    private init(storage: UserDefaults = .standard) {
        self.storage = storage
        if let saved = storage.array(forKey: key) as? [String] {
            countries = Set(saved)
        } else {
            countries = []
        }
    }
}

extension FavouritesManager {
    func contains(_ country: Country) -> Bool {
        countries.contains(country.id)
    }
    
    func add(_ country: Country) {
        countries.insert(country.id)
        save()
    }
    
    func remove(_ country: Country) {
        countries.remove(country.id)
        save()
    }
    
    private func save() {
        storage.set(Array(countries), forKey: key)
    }
}
