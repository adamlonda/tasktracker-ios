import SwiftUI

struct WithInMemory<Content: View>: View {
    @ViewBuilder var content: (UserDefaults) -> Content

    init(@ViewBuilder content: @escaping (UserDefaults) -> Content) {
        self.content = content
    }

    var body: some View {
        let userDefaults = UserDefaults.inMemory
        content(userDefaults)
    }
}
