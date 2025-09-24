import Testing
@testable import FinalProject
import Foundation

// MARK: - Mock Services

final class MockCountriesService: CountriesServiceProtocol {
    private let response: CountriesResponse?
    private let error: Error?

    init(response: CountriesResponse? = nil, error: Error? = nil) {
        self.response = response
        self.error = error
    }

    func fetchPage(urlString: String?) async throws -> CountriesResponse {
        if let error = error {
            throw error
        }
        if let response = response {
            return response
        }
        return CountriesResponse(
            data: [],
            links: [],
            metadata: Metadata(currentOffset: 0, totalCount: 0)
        )
    }
}

final class MockCountriesServiceSequence: CountriesServiceProtocol {
    private var responses: [CountriesResponse]
    private var callIndex = 0
    private let error: Error?

    init(responses: [CountriesResponse], error: Error? = nil) {
        self.responses = responses
        self.error = error
    }

    func fetchPage(urlString: String?) async throws -> CountriesResponse {
        if let error = error {
            throw error
        }
        guard callIndex < responses.count else {
            return CountriesResponse(data: [], links: [], metadata: Metadata(currentOffset: 0, totalCount: 0))
        }
        let response = responses[callIndex]
        callIndex += 1
        return response
    }
}
