import SwiftUI

@MainActor
class CountriesViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var nextPageURL: String? =
        "https://wft-geo-db.p.rapidapi.com/v1/geo/countries?limit=10"

    private let headers = [
        "x-rapidapi-key": "af89b7b859msh76f4aa94196b1c7p16ea9djsnb51a2f8c0353",
        "x-rapidapi-host": "wft-geo-db.p.rapidapi.com"
    ]

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
        guard !isLoading,
              let urlString = urlString,
              let url = URL(string: urlString) else { return }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = jsonObject["message"] as? String {
                errorMessage = "API error: \(message)"
                isLoading = false
                return
            }

            let decoded = try JSONDecoder().decode(CountriesResponse.self, from: data)
            countries.append(contentsOf: decoded.data)

            if let nextLink = decoded.links.first(where: { $0.rel == "next" }) {
                let href = nextLink.href
                nextPageURL = href.hasPrefix("http") ?
                    href :
                    "https://wft-geo-db.p.rapidapi.com" + href
            } else {
                nextPageURL = nil
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

