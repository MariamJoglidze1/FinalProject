import SwiftUI

@main

struct FinalProjectApp: App {
    @State private var favourites = Favourites()

    var body: some Scene {
        WindowGroup {
            CountriesListView()
        }
               .environment(favourites)
    }
}


