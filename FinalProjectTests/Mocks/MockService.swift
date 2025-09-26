import Foundation
@testable import FinalProject

final class MockCountriesService: CountriesServiceProtocol {
    var result: Result<CountriesResponse, Error>?
    var callCount = 0

    func fetchPage(urlString: String?) async throws -> CountriesResponse {
        callCount += 1
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
