import SwiftUI

@Observable
class Favorites {
    private var countries: Set<String>

    private let key = "Favorites"

    init() {

        countries = []
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

    func save() {
    }
}
