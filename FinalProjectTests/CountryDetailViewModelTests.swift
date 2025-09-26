import Testing
import SwiftUI
import Foundation
import MapKit
@testable import FinalProject

@MainActor
struct CountryDetailsViewModelTests {
    
    // MARK: - Success
    
    @Test
    func testLoadDataSuccess() async {
        let service = MockWikidataService()
        service.response = CountryDetailsResponse(
            flagURL: nil,
            capital: "Paris",
            population: 1000,
            continent: "Europe",
            latitude: 12.34,
            longitude: 56.78
        )
        
        let country = Country(
            code: "FR",
            currencyCodes: ["EUR"],
            name: "France",
            wikiDataId: "Q142"
        )
        let viewModel = CountryDetailsViewModel(service: service, country: country)
        
        await viewModel.loadData()
        
        #expect(viewModel.details?.capital == "Paris")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.alertParameters.wrappedValue == nil)
    }
    
    // MARK: - Failure
    
    @Test
    func testLoadDataFailure() async {
        let service = MockWikidataService()
        service.shouldThrow = true
        
        let country = Country(
            code: "FR",
            currencyCodes: ["EUR"],
            name: "France",
            wikiDataId: "Q142"
        )
        let viewModel = CountryDetailsViewModel(service: service, country: country)
        
        await viewModel.loadData()
        
        #expect(viewModel.details == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.alertParameters.wrappedValue != nil)
    }
    
    // MARK: - Derived properties
    
    @Test
    func testPopulationText() async throws {
        let service = MockWikidataService()
        service.response = CountryDetailsResponse(
            flagURL: URL(string: "https://test.com/flag.png"),
            capital: "Test Capital",
            population: 1_000_000,
            continent: "Test Continent",
            latitude: 10.0,
            longitude: 20.0
        )
        
        let country = Country(
            code: "TL",
            currencyCodes: ["TST"],
            name: "Testland",
            wikiDataId: "Q123"
        )
        let viewModel = CountryDetailsViewModel(service: service, country: country)
        await viewModel.loadData()
        
        let text = try #require(viewModel.populationText)
        let digitsOnly = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        #expect(digitsOnly == "1000000")
    }
    
    @Test
    func testCountryInfoDataSource() async {
        let service = MockWikidataService()
        service.response = CountryDetailsResponse(
            capital: "MockCity",
            population: 42,
            continent: "MockContinent"
        )
        
        let country = Country(
            code: "Mockia",
            currencyCodes: ["EUR"],
            name: "Mockia",
            wikiDataId: "Q999"
        )
        
        let viewModel = CountryDetailsViewModel(service: service, country: country)
        await viewModel.loadData()
        let dataSource = viewModel.countryInfoDataSource
        
        #expect(dataSource.count == 3)
        #expect(dataSource.contains { $0.value == "MockCity" })
        #expect(dataSource.contains { $0.value == "42" })
        #expect(dataSource.contains { $0.value == "MockContinent" })
    }
    
    @Test
    func testMapCoordinate() async {
        let service = MockWikidataService()
        service.response = CountryDetailsResponse(latitude: 1.23, longitude: 4.56)
        let country = Country(
            code: "Coordland",
            currencyCodes: ["EUR"],
            name: "Coordland",
            wikiDataId: "Q888"
        )
        
        let viewModel = CountryDetailsViewModel(service: service, country: country)
        await viewModel.loadData()
        let coordinate = viewModel.mapCoordinate()
        
        #expect(coordinate?.latitude == 1.23)
        #expect(coordinate?.longitude == 4.56)
    }
    
    // MARK: - Favourites
    
    @Test
    func testToggleFavourite() {
        let service = MockWikidataService()
        let country = Country(
            code: "Toggleland",
            currencyCodes: ["EUR"],
            name: "Toggleland",
            wikiDataId: "Q777"
        )
        
        let viewModel = CountryDetailsViewModel(service: service, country: country)
        
        FavouritesManager.shared.remove(country)
        
        viewModel.toggleFavourite()
        #expect(FavouritesManager.shared.contains(country))
        
        viewModel.toggleFavourite()
        #expect(!FavouritesManager.shared.contains(country))
    }
    
    // MARK: - AlertParameters
    
    @Test
    func testAlertParametersBindingGetAndSet() {
        let vm = makeViewModel()
        
        #expect(vm.alertParameters.wrappedValue == nil)
        vm.alertParameters.wrappedValue = AlertParameters(message: "Test error")
        #expect(vm.alertParameters.wrappedValue?.message == "Test error")
    }
    
    // MARK: - CountryInfoModel
    
    @Test
    func testCountryInfoModelIdIsUnique() {
        let model1 = CountryDetailsViewModel.CountryInfoModel(title: "Capital", value: "Paris")
        let model2 = CountryDetailsViewModel.CountryInfoModel(title: "Capital", value: "Paris")
        #expect(model1.id != model2.id)
    }
    
    // MARK: - CountryInfoDataSource branches
    
    @Test
    func testCountryInfoDataSource_emptyWhenNoDetails() {
        let vm = makeViewModel()
        #expect(vm.countryInfoDataSource.isEmpty)
    }
    
    @Test
    func testCountryInfoDataSource_onlyCapital() async {
        let vm = makeViewModel(with: CountryDetailsResponse(capital: "Paris"))
        await vm.loadData()
        
        let items = vm.countryInfoDataSource
        
        #expect(items.count == 1)
        #expect(items.first?.value == "Paris")
    }
    
    @Test
    func testCountryInfoDataSource_onlyPopulation() async {
        let vm = makeViewModel(with: CountryDetailsResponse(population: 123))
        await vm.loadData()
        
        let items = vm.countryInfoDataSource
        #expect(items.count == 1)
        #expect(items.first?.value == "123")
    }
    
    @Test
    func testCountryInfoDataSource_onlyContinent() async {
        let vm = makeViewModel(with: CountryDetailsResponse(continent: "Europe"))
        await vm.loadData()
        
        let items = vm.countryInfoDataSource
        #expect(items.count == 1)
        #expect(items.first?.value == "Europe")
    }
    
    // MARK: - MapCoordinate branches
    
    @Test
    func testMapCoordinate_nilWhenMissing() {
        let vm = makeViewModel()
        #expect(vm.mapCoordinate() == nil)
    }
    
    // MARK: - Toggle Favourite
    
    @Test
    func testToggleFavourite_addAndRemove() {
        let vm = makeViewModel()
        let country = vm.selectedCountry
        FavouritesManager.shared.remove(country)
        
        vm.toggleFavourite()
        #expect(FavouritesManager.shared.contains(country))
        
        vm.toggleFavourite()
        #expect(!FavouritesManager.shared.contains(country))
    }
    
    // MARK: - LoadData branches
    
    @Test
    func testLoadDataFailure_setsErrorMessage() async {
        let service = MockWikidataService()
        service.shouldThrow = true
        let country = Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")
        let vm = CountryDetailsViewModel(service: service, country: country)
        
        await vm.loadData()
        
        #expect(vm.details == nil)
        #expect(vm.isLoading == false)
        #expect(vm.alertParameters.wrappedValue?.message?.contains("Failed to load details") == true)
    }
    
    @Test
    func testPopulationText_whenPopulationExists() async throws {
        let vm = makeViewModel(with: CountryDetailsResponse(population: 1_000_000))
        await vm.loadData()
        
        let text = try #require(vm.populationText)
        let digitsOnly = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        #expect(digitsOnly == "1000000")
    }
    
    @Test
    func testPopulationText_whenPopulationIsNil() {
        let vm = makeViewModel(with: CountryDetailsResponse(population: nil))
        #expect(vm.populationText == nil)
    }
    
    // MARK: - Coverage fillers
    
    @Test
    func testInitSetsDefaults() {
        let vm = makeViewModel()
        #expect(vm.isLoading == false)
        #expect(vm.details == nil)
        #expect(vm.alertParameters.wrappedValue == nil)
    }
    
    @Test
    func testAlertParametersCoversGetAndSet() {
        let vm = makeViewModel()
        _ = vm.alertParameters.wrappedValue // triggers getter
        vm.alertParameters.wrappedValue = AlertParameters(message: "Boom") // setter
        #expect(vm.alertParameters.wrappedValue?.message == "Boom")
    }
    
    @Test
    func testCountryInfoModelIdInitialization() {
        let model = CountryDetailsViewModel.CountryInfoModel(title: "Foo", value: "Bar")
        _ = model.id
        #expect(!model.id.uuidString.isEmpty)
    }
    
    // MARK: - Helpers
    
    func makeViewModel(with details: CountryDetailsResponse? = nil) -> CountryDetailsViewModel {
        let service = MockWikidataService()
        service.response = details
        let country = Country(
            code: "TC",
            currencyCodes: ["TST"],
            name: "TestCountry",
            wikiDataId: "Q999"
        )
        let viewModel = CountryDetailsViewModel(service: service, country: country)
        return viewModel
    }
}
