import SwiftUI

@MainActor
@Observable
final class CountriesViewModel {
    private(set) var countries: [Country] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    private var nextPageURL: String? = {
        let code = Locale.currentLanguageCode
        return "https://wft-geo-db.p.rapidapi.com/v1/geo/countries?limit=10&languageCode=\(code)"
    }()
    
    private let service: CountriesServiceProtocol
    
    init(service: CountriesServiceProtocol = CountriesService()) {
        self.service = service
    }
    
    func fetchCountries() async {
        await fetchPage(urlString: nextPageURL)
    }
    
    func retry() async {
        await fetchCountries()
    }
    
    func loadMoreIfNeeded(current country: Country) async {
        guard let index = countries.firstIndex(of: country),
              index >= countries.count - 2 else { return }
        await fetchCountries()
    }
    
    // MARK: - Networking
    private func fetchPage(urlString: String?) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.fetchPage(urlString: urlString)
            countries.append(contentsOf: response.data)
            
            if let nextLink = response.links.first(where: { $0.rel == "next" }) {
                var href = nextLink.href
                // Ensure languageCode always included
                if !href.contains("languageCode") {
                    href += (href.contains("?") ? "&" : "?") + "languageCode=\(Locale.currentLanguageCode)"
                }
                nextPageURL = href.hasPrefix("http") ? href : "https://wft-geo-db.p.rapidapi.com" + href
            } else {
                nextPageURL = nil
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
