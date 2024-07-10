import ComposableArchitecture
import Reducers
import SwiftUI
import UI

@main
struct TaskTrackerApp: App {

    @MainActor static let store = Store(initialState: AppReducer.State()) {
        AppReducer()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
