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
    
    private var dataIsFullyLoaded: Bool = false
    private var previousFetchCountriesMethodCallDate: Date?
    
    private let service: CountriesServiceProtocol
    
    init(
        service: CountriesServiceProtocol
    ) {
        self.service = service
    }
}

extension CountriesViewModel {
    func getNextPageURL() -> String? {
        nextPageURL
    }
    
    func fetchCountries() async {
        await fetchCountries(urlString: nextPageURL)
    }
    
    func retry() async {
        await fetchCountries()
    }
    
    func loadMoreIfNeeded(current country: Country) async {
        guard let index = countries.firstIndex(of: country),
              index > countries.count - 2 else { return }
        
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
        guard !isLoading, !dataIsFullyLoaded else { return }
        
        // Check the time difference due to the limitation from Server. 1 request in 3 second.
        if let previousCallDate = previousFetchCountriesMethodCallDate {
            let timeDifference = Date().timeIntervalSince(previousCallDate)
            
            if timeDifference < 3 {
                let delayNeeded = 3.0 - timeDifference
                
                if delayNeeded > 0 {
                    // Wait for the remaining time
                    isLoading = true
                    let nanoseconds = UInt64(delayNeeded * 1_000_000_000)
                    try? await Task.sleep(nanoseconds: nanoseconds)
                }
            }
        }
        
        errorMessage = nil
        isLoading = true
        previousFetchCountriesMethodCallDate = Date()

        defer {
            isLoading = false
        }
        
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
                dataIsFullyLoaded = true
                nextPageURL = nil
            }
        } catch {
            var errorMsg: String {
                if let apiError = error as? FPError, apiError.statusCode == 429 {
                    apiError.message ?? "Too many requests. Please try again later."
                } else {
                    "Error: \(error.localizedDescription)"
                }
            }
            
            errorMessage = .init(
                message: errorMsg,
                actionTitle: "Retry",
                action: { [weak self] in
                    Task {
                        await self?.fetchCountries(urlString: urlString)
                    }
                }
            )
        }
    }
}
