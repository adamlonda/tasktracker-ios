import Models
import SwiftUI

struct PriorityPicker: View {
    @Binding var selection: Priority

    var body: some View {
        Picker("Priority", selection: $selection) {
            ForEach(Priority.allCases) { priority in
                Label(priority.name, systemImage: priority.imageName)
                    .tag(priority)
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var selection: Priority = .normal
        var body: some View {
            PriorityPicker(selection: $selection)
        }
    }
    return Preview()
}
