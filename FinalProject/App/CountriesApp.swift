import SwiftUI

@main
struct FinalProjectApp: App {
    @State private var favourites = FavouritesManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            CountriesListView()
        }
        .environment(favourites)
    }
}
