import SwiftUI

extension Label where Title == Text, Icon == Image {
    init(_ key: LocalizedStringKey, bundle: Bundle, systemImage: String) {
        self.init {
            Text(key, bundle: bundle)
        } icon: {
            Image(systemName: systemImage)
        }
    }
}

#Preview {
    Label("button.label.move_to_trash", bundle: .module, systemImage: "trash")
}
