import Testing
import Foundation
@testable import FinalProject
@MainActor

// MARK: - Tests
struct DetailsViewModelTests {
    
    private let sampleCountry = Country(
        code: "GE",
        currencyCodes: ["GEL"],
        name: "Georgia",
        wikiDataId: "Q230"
    )
    
    @Test @MainActor
    func testLoadSuccess() async throws {
        var mockService = MockWikidataService()
        mockService.sampleDetails = CountryDetailsResponse(
            flagURL: URL(string: "https://example.com/flag.png"),
            capital: "Tbilisi",
            population: 3729600,
            continent: "Asia",
            latitude: 41.7,
            longitude: 44.8
        )
        
        let viewModel = CountryDetailsViewModel(service: mockService, country: sampleCountry)

        await viewModel.loadData()
        
        #expect(viewModel.details?.capital == "Tbilisi")
        #expect(viewModel.details?.population == 3729600)
        #expect(viewModel.alertParameters == nil)
        #expect(viewModel.isLoading == false)
        let digitsOnly = viewModel.populationText?.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        #expect(digitsOnly == "3729600")
    }
    
    @Test @MainActor
    func testLoadFailure() async throws {
        var mockService = MockWikidataService()
        mockService.shouldThrow = true
        
        let viewModel = CountryDetailsViewModel(service: mockService, country: sampleCountry)

        await viewModel.loadData()
        
        #expect(viewModel.details == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test @MainActor
    func testIsLoadingState() async throws {
        let mockService = MockWikidataService()
        let viewModel = CountryDetailsViewModel(service: mockService, country: sampleCountry)

        let task = Task {
            #expect(viewModel.isLoading == false)
            await viewModel.loadData()
        }

        try await Task.sleep(nanoseconds: 10_000_000)
        #expect(viewModel.isLoading == true) 

        await task.value
        #expect(viewModel.isLoading == false)
    }
}
