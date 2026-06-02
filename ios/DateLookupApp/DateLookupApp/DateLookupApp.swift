import SwiftUI

@main
struct DateLookupApp: App {
    @StateObject private var store = CalendarStore(apiClient: .live)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

