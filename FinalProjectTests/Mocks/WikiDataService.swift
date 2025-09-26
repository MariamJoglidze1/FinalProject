import Foundation
import Testing
@testable import FinalProject
@MainActor

// MARK: - Mock Service
final class MockWikidataService: WikidataServiceProtocol {
    var shouldThrow = false
    var response: CountryDetailsResponse?
    
    func fetchCountryDetails(for wikiDataId: String) async throws -> CountryDetailsResponse {
        if shouldThrow {
            throw URLError(.badServerResponse)
        }
        return response ?? CountryDetailsResponse(
            flagURL: URL(string: "https://test.com/flag.png"),
            capital: "Test Capital",
            population: 123456,
            continent: "Test Continent",
            latitude: 10.0,
            longitude: 20.0
        )
    }
    
    func fetchLabel(for entityId: String) async throws -> String {
        "Mock Label"
    }
}
