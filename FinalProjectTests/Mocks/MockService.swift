import Foundation
@testable import FinalProject

final class MockCountriesService: CountriesServiceProtocol {
    var result: Result<CountriesResponse, Error>?
    
    func fetchPage(urlString: String?) async throws -> CountriesResponse {
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        case .none:
            fatalError("Mock result not set")
        }
    }
}
