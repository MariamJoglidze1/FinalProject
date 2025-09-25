import SwiftUI
import MapKit

@MainActor
@Observable
final class CountryDetailsViewModel {
    private(set) var details: CountryDetails?
    private(set) var isLoading = false
    private var errorMessage: AlertParameters?
    
    var alertParameters: Binding<AlertParameters?> {
        Binding(
            get: { self.errorMessage },
            set: { self.errorMessage = $0 }
        )
    }
    
    private let service: WikidataServiceProtocol
    private(set) var selectedCountry: Country
    init(
        service: WikidataServiceProtocol = WikidataService(),
        country: Country,
    ) {
        self.service = service
        self.selectedCountry = country
    }
}

extension CountryDetailsViewModel {
    var populationText: String? {
        details?.population?.formattedWithSeparator
    }
    
    func mapCoordinate() -> CLLocationCoordinate2D? {
        guard let lat = details?.latitude,
              let lon = details?.longitude else {
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func toggleFavourite() {
        if FavouritesManager.shared.contains(selectedCountry) {
            FavouritesManager.shared.remove(selectedCountry)
        } else {
            FavouritesManager.shared.add(selectedCountry)
        }
    }
    
    // MARK: - Data loading
    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await service.fetchCountryDetails(for: selectedCountry.wikiDataId)
            self.details = result
        } catch {
            self.errorMessage = .init(message: "Failed to load details: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
