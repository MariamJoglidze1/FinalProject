import Testing
import Foundation
@testable import FinalProject

struct FavouritesTests {
    
    // MARK: - Test Helpers
    private var sampleCountry: Country {
        Country(code: "GE",
                currencyCodes: ["GEL"],
                name: "Georgia",
                wikiDataId: "Q230")
    }
    
    @Test
    func testInitialEmptyState() async throws {
        let storage = UserDefaults(suiteName: #function)!
        storage.removePersistentDomain(forName: #function)
        
        let favourites = FavouritesManager(storage: storage)
        try await Task.sleep(nanoseconds: 10_000_000)
        #expect(!favourites.contains(sampleCountry))
    }
    
    @Test
    func testAddCountry() async throws {
        let storage = UserDefaults(suiteName: #function)!
        storage.removePersistentDomain(forName: #function)
        
        let favourites = FavouritesManager(storage: storage)
        favourites.add(sampleCountry)
        try await Task.sleep(nanoseconds: 10_000_000)
        
        #expect(favourites.contains(sampleCountry))
    }
    
    @Test
    func testRemoveCountry() async throws {
        let storage = UserDefaults(suiteName: #function)!
        storage.removePersistentDomain(forName: #function)
        
        let favourites = FavouritesManager(storage: storage)
        favourites.add(sampleCountry)
        favourites.remove(sampleCountry)
        try await Task.sleep(nanoseconds: 10_000_000)
        
        #expect(!favourites.contains(sampleCountry))
    }
    
    @Test
        func testPersistenceAcrossInstances() async throws {
            let storage = UserDefaults(suiteName: #function)!
            storage.removePersistentDomain(forName: #function)
            
            var favourites = FavouritesManager(storage: storage)
            favourites.add(sampleCountry)
            try await Task.sleep(nanoseconds: 10_000_000)
            
            favourites = FavouritesManager(storage: storage)
            try await Task.sleep(nanoseconds: 10_000_000)
            
            #expect(favourites.contains(sampleCountry))
        }
    }
