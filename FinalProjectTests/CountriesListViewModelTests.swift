import Testing
import Foundation
@testable import FinalProject
internal import SwiftUI
@MainActor

struct CountriesListViewModelTests {
    @Test
    func initialState_isEmpty() async throws {
        let vm = CountriesViewModel(service: MockCountriesService())
        
        #expect(vm.countries.isEmpty)
        #expect(vm.isLoading == false)
        #expect(vm.alertParameters.wrappedValue == nil)
    }
    
    @Test
    func fetchCountries_successful() async throws {
        let response = CountriesResponse(
            data: [Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")],
            links: [],
            metadata: Metadata(currentOffset: 0, totalCount: 1)
        )
        let service = MockCountriesService(response: response)
        let vm = CountriesViewModel(service: service)
        
        await vm.fetchCountries()
        
        #expect(vm.countries.count == 1)
        #expect(vm.countries.first?.name == "Georgia")
        #expect(vm.alertParameters.wrappedValue == nil)
    }
    
    @Test
    func fetchCountries_error() async throws {
        let service = MockCountriesService(error: URLError(.badServerResponse))
        let vm = CountriesViewModel(service: service)
        
        await vm.fetchCountries()
        
        #expect(vm.countries.isEmpty)
        #expect(vm.alertParameters.wrappedValue != nil)
    }
    
    @Test
    func loadMoreIfNeeded_fetchesNextPage() async throws {
        let firstResponse = CountriesResponse(
            data: [Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")],
            links: [Link(rel: "next", href: "/v1/geo/countries?page=2")],
            metadata: Metadata(currentOffset: 0, totalCount: 2)
        )
        
        let secondResponse = CountriesResponse(
            data: [Country(code: "AM", currencyCodes: ["AMD"], name: "Armenia", wikiDataId: "Q399")],
            links: [],
            metadata: Metadata(currentOffset: 1, totalCount: 2)
        )
        
        let service = MockCountriesServiceSequence(responses: [firstResponse, secondResponse])
        let vm = CountriesViewModel(service: service)
        
        await vm.fetchCountries()
        #expect(vm.countries.count == 1)
        #expect(vm.countries.first?.name == "Georgia")
        
        if let last = vm.countries.last {
            await vm.loadMoreIfNeeded(current: last)
        }
        
        #expect(vm.countries.count == 2)
        #expect(vm.countries.last?.name == "Armenia")
    }
}
