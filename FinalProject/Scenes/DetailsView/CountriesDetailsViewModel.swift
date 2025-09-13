import Foundation

@MainActor
class DetailsViewModel: ObservableObject {
    @Published var details: CountryDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: WikidataServicing
    
    init(service: WikidataServicing = WikidataService()) {
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
}

