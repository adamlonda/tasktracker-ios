import Models
import SwiftUI

struct RecurrencePicker: View {

    var title: String
    @Binding var selection: Recurrence

    init(_ title: String, selection: Binding<Recurrence>) {
        self.title = title
        self._selection = selection
    }

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(Recurrence.allCases) { recurrence in
                Text(recurrence.name)
                    .tag(recurrence)
            }
        }
    }
}

extension Recurrence {
    var name: String {
        switch self {
        case .never:
            return "Never"
        case .daily:
            return "Every day"
        case .weekly:
            return "Every week"
        case .monthly:
            return "Every month"
        case .annually:
            return "Every year"
        }
    }
}

#Preview {
    struct Preview: View {
        @State var selection: Recurrence = .never
        var body: some View {
            Form {
                Section {
                    RecurrencePicker("Recurrence", selection: $selection)
                }
            }
        }
    }
    return Preview()
}
