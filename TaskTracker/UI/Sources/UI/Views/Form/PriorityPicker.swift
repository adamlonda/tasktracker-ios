import Models
import SwiftUI

struct PriorityPicker: View {

    var title: String
    @Binding var selection: Priority

    init(_ title: String, selection: Binding<Priority>) {
        self.title = title
        self._selection = selection
    }

    var body: some View {
        Picker(title, selection: $selection) {
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
            Form {
                Section {
                    PriorityPicker("Priority", selection: $selection)
                }
            }
        }
    }
    return Preview()
}
