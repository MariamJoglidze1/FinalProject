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
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchPage(urlString: String?) async throws -> CountriesResponse {
        guard let urlString, let url = URL(string: urlString) else {
            throw FPErrorCode.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
            let message = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["message"] as? String
            throw FPError(statusCode: 429, message: message)
        }
        
        return try JSONDecoder().decode(CountriesResponse.self, from: data)
    }
}
