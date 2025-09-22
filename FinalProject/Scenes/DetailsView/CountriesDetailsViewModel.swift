import Foundation

@MainActor
@Observable
final class DetailsViewModel {
    private(set) var details: CountryDetails?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    private let service: WikidataServiceProtocol
    private let country: Country
    
    init(
        service: WikidataServiceProtocol = WikidataService(),
        country: Country
    ) {
        self.service = service
        self.country = country
    }
    
    var populationText: String? {
        details?.population?.formattedWithSeparator
    }
    
    // MARK: - Data loading
    func load(for wikiDataId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await service.fetchCountryDetails(for: wikiDataId)
            self.details = result
        } catch {
            self.errorMessage = "Failed to load details: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
