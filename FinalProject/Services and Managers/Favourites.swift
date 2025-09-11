import SwiftUI

@Observable
class Favourites {
    private var countries: Set<String>
    private let key = "Favorites"

    init() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            countries = Set(saved)
        } else {
            countries = []
        }
    }

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
        UserDefaults.standard.set(Array(countries), forKey: key)
    }
}


