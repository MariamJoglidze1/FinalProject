import Foundation

protocol CountriesServiceProtocol {
    func fetchPage(urlString: String?) async throws -> CountriesResponse
}


struct CountriesService: CountriesServiceProtocol {
    private let baseURL = "https://wft-geo-db.p.rapidapi.com"
    private let headers = [
        "x-rapidapi-key": "af89b7b859msh76f4aa94196b1c7p16ea9djsnb51a2f8c0353",
        "x-rapidapi-host": "wft-geo-db.p.rapidapi.com"
    ]
    
    func fetchPage(urlString: String?) async throws -> CountriesResponse {
        guard let urlString, let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(CountriesResponse.self, from: data)
    }
}
