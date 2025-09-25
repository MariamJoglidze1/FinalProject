import Foundation
import Testing
@testable import FinalProject
@MainActor

// MARK: - Mock Service
struct MockWikidataService: WikidataServiceProtocol {
    var shouldThrow = false
    var sampleDetails: CountryDetails?
    
    func fetchCountryDetails(for wikiDataId: String) async throws -> CountryDetails {
        try await Task.sleep(nanoseconds: 100_000_000)
        if shouldThrow { throw URLError(.badServerResponse) }
        return sampleDetails ?? CountryDetails(
            flagURL: URL(string: "https://example.com/flag.png"),
            capital: "Tbilisi",
            population: 3729600,
            continent: "Asia",
            latitude: 41.7,
            longitude: 44.8
        )
    }
    
    func fetchLabel(for entityId: String) async throws -> String { "MockLabel" }
}
