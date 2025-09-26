import Testing
import SwiftUI
@testable import FinalProject

@MainActor
struct CountriesViewModelTests {
    
    // MARK: - Success Tests
    
    @Test
    func testFetchCountriesSuccess() async {
        let service = MockCountriesService()
        let countries = [
            Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230"),
            Country(code: "FR", currencyCodes: ["EUR"], name: "France", wikiDataId: "Q142")
        ]
        let response = CountriesResponse(
            data: countries,
            links: [],
            metadata: Metadata(currentOffset: 0, totalCount: 2)
        )
        service.result = .success(response)
        
        let viewModel = CountriesViewModel(service: service)
        await viewModel.fetchCountries()
        
        #expect(viewModel.countries == countries)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.alertParameters.wrappedValue == nil)
    }
    
    @Test
    func testFetchCountriesSuccess_withNextPage() async {
        let service = MockCountriesService()
        let country = Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")
        let response = CountriesResponse(
            data: [country],
            links: [Link(rel: "next", href: "/v1/geo/countries?page=2")],
            metadata: Metadata(currentOffset: 0, totalCount: 1)
        )
        service.result = .success(response)
        
        let viewModel = CountriesViewModel(service: service)
        await viewModel.fetchCountries()
        
        #expect(viewModel.countries == [country])
        #expect(viewModel.alertParameters.wrappedValue == nil)
        #expect(viewModel.getNextPageURL()?.contains("page=2") == true)
    }
    
    // MARK: - Failure Tests
    
    @Test
    func testFetchCountriesFailureSetsErrorMessage() async {
        let service = MockCountriesService()
        service.result = .failure(URLError(.badServerResponse))
        
        let viewModel = CountriesViewModel(service: service)
        await viewModel.fetchCountries()
        
        #expect(viewModel.countries.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.alertParameters.wrappedValue != nil)
        #expect(viewModel.alertParameters.wrappedValue?.message?.contains("Error") == true)
    }
    
    // MARK: - Retry & Pagination
    
    @Test
    func testRetryCallsFetchAgain() async {
        let service = MockCountriesService()
        let countries = [Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")]
        let response = CountriesResponse(
            data: countries,
            links: [],
            metadata: Metadata(currentOffset: 0, totalCount: 1)
        )
        service.result = .success(response)
        
        let viewModel = CountriesViewModel(service: service)
        await viewModel.retry()
        
        #expect(viewModel.countries == countries)
    }
    
    @Test
    func testLoadMoreIfNeededTriggersPagination() async {
        let service = MockCountriesService()
        
        let first = Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")
        let second = Country(code: "FR", currencyCodes: ["EUR"], name: "France", wikiDataId: "Q142")
        
        let response1 = CountriesResponse(
            data: [first],
            links: [Link(rel: "next", href: "/v1/geo/countries?page=2")],
            metadata: Metadata(currentOffset: 0, totalCount: 1)
        )
        service.result = .success(response1)
        
        let viewModel = CountriesViewModel(service: service)
        await viewModel.fetchCountries()
        
        let response2 = CountriesResponse(
            data: [second],
            links: [],
            metadata: Metadata(currentOffset: 1, totalCount: 2)
        )
        service.result = .success(response2)
        
        if let firstCountry = viewModel.countries.first {
            await viewModel.loadMoreIfNeeded(current: firstCountry)
        }
        
        #expect(viewModel.countries.count == 2)
        #expect(viewModel.countries.contains(where: { $0.code == "FR" }))
    }
    
    // MARK: - Favourites
    
    @Test
    func testFavouriteButtonDidTapToggles() async {
        let service = MockCountriesService()
        service.result = .success(
            CountriesResponse(data: [], links: [], metadata: Metadata(currentOffset: 0, totalCount: 0))
        )
        
        let viewModel = CountriesViewModel(service: service)
        let country = Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")
        
        viewModel.favouriteButtonDidTap(country: country)
        #expect(FavouritesManager.shared.contains(country))
        
        viewModel.favouriteButtonDidTap(country: country)
        #expect(!FavouritesManager.shared.contains(country))
    }
    
    // MARK: - Extended Coverage Tests
    
    @Test
    func testFetchCountriesDoesNotRunWhenAlreadyLoading() async {
        let service = MockCountriesService()
        let response = CountriesResponse(
            data: [Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")],
            links: [],
            metadata: Metadata(currentOffset: 0, totalCount: 1)
        )
        service.result = .success(response)
        let viewModel = CountriesViewModel(service: service)

        // Call the function the first time. The isLoading flag will be set to true internally.
        await viewModel.fetchCountries()

        // Call it a second time. The guard clause should prevent a second API call.
        await viewModel.fetchCountries()
        
        #expect(!viewModel.countries.isEmpty)
        #expect(service.callCount == 1)
    }
    
    @Test
    func testNextPageURLAlreadyContainsLanguageCode() async {
        let service = MockCountriesService()
        let response = CountriesResponse(
            data: [Country(code: "FR", currencyCodes: ["EUR"], name: "France", wikiDataId: "Q142")],
            links: [Link(rel: "next", href: "/v1/geo/countries?page=2&languageCode=en")],
            metadata: Metadata(currentOffset: 0, totalCount: 1)
        )
        service.result = .success(response)
        
        let viewModel = CountriesViewModel(service: service)
        await viewModel.fetchCountries()
        
        #expect(viewModel.getNextPageURL()?.contains("languageCode=en") == true)
    }
    
    @Test
    func testErrorActionRetriesFetch() async throws {
        let service = MockCountriesService()
        let country = Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")
        
        service.result = .failure(URLError(.notConnectedToInternet))
        let viewModel = CountriesViewModel(service: service)
        await viewModel.fetchCountries()
        
        service.result = .success(
            CountriesResponse(
                data: [country],
                links: [],
                metadata: Metadata(currentOffset: 0, totalCount: 1)
            )
        )
        
        viewModel.alertParameters.wrappedValue?.action?()
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.countries == [country])
    }
}
