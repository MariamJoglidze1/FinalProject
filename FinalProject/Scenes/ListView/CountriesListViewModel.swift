import SwiftUI

@MainActor
@Observable
final class CountriesViewModel {
    private(set) var countries: [Country] = []
    private(set) var isLoading = false
    private var errorMessage: AlertParameters?
    
    var alertParameters: Binding<AlertParameters?> {
        Binding(
            get: { self.errorMessage },
            set: { self.errorMessage = $0 }
        )
    }
    
    private var nextPageURL: String? = {
        let code = Locale.currentLanguageCode
        return "https://wft-geo-db.p.rapidapi.com/v1/geo/countries?limit=10&languageCode=\(code)"
    }()
    
    private let service: CountriesServiceProtocol
    
    init(
        service: CountriesServiceProtocol
    ) {
        self.service = service
    }
    
    func fetchCountries() async {
        await fetchCountries(urlString: nextPageURL)
    }
    
    func retry() async {
        await fetchCountries()
    }
    
    func loadMoreIfNeeded(current country: Country) async {
        guard let index = countries.firstIndex(of: country),
              index >= countries.count - 2 else { return }
        
        await fetchCountries()
    }
    
    //MARK: Actions
    func favouriteButtonDidTap(country: Country) {
        if FavouritesManager.shared.contains(country) {
            FavouritesManager.shared.remove(country)
        } else {
            FavouritesManager.shared.add(country)
        }
    }
    
    // MARK: - Networking
    private func fetchCountries(urlString: String?) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.fetchPage(urlString: urlString)
            countries.append(contentsOf: response.data)
            
            if let nextLink = response.links.first(where: { $0.rel == "next" }) {
                var href = nextLink.href
                if !href.contains("languageCode") {
                    href += (href.contains("?") ? "&" : "?") + "languageCode=\(Locale.currentLanguageCode)"
                }
                nextPageURL = href.hasPrefix("http") ? href : "https://wft-geo-db.p.rapidapi.com" + href
            } else {
                nextPageURL = nil
            }
        } catch {
            errorMessage = .init(
                message: "Error: \(error.localizedDescription)",
                actionTitle: "Retry", // TODO: Localization
                action: { [weak self] in
                    Task {
                        await self?.fetchCountries()
                    }
                })
        }
        
        isLoading = false
    }
}
