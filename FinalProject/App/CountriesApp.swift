import SwiftUI

@main
struct FinalProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            CountriesListView()
        }
    }
}
