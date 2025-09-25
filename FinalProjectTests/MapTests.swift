import Testing
import MapKit
@testable import FinalProject
@MainActor

struct DetailsViewTests {
    
    @Test func testMapCoordinateExistsWhenDetailsHaveCoordinates() async throws {
        let details = CountryDetails(
            flagURL: nil,
            capital: "Tbilisi",
            population: 3_700_000,
            continent: "Europe",
            latitude: 41.7151,
            longitude: 44.8271
        )
        let dummyCountry = Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")
        let view = DetailsView(country: dummyCountry)
        
        let coordinate = view.mapCoordinate(from: details)
        
        #expect(coordinate?.latitude == 41.7151)
        #expect(coordinate?.longitude == 44.8271)
    }
    
    @Test func testMapCoordinateIsNilWhenDetailsHaveNoCoordinates() async throws {
        let details = CountryDetails(
            flagURL: nil,
            capital: "Tbilisi",
            population: 3_700_000,
            continent: "Europe",
            latitude: nil,
            longitude: nil
        )
        let dummyCountry = Country(code: "GE", currencyCodes: ["GEL"], name: "Georgia", wikiDataId: "Q230")
        let view = DetailsView(country: dummyCountry)
        
        let coordinate = view.mapCoordinate(from: details)
        
        #expect(coordinate == nil)
    }
}
