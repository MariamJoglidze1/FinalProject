import Foundation

@MainActor
class DetailsViewModel: ObservableObject {
    @Published private(set) var details: CountryDetails?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let service: WikidataServiceProtocol
    
    init(service: WikidataServiceProtocol = WikidataService()) {
    self.service = service
    }
    
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

    var populationText: String? {
        details?.population?.formattedWithSeparator
    }

}

