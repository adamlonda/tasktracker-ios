import SwiftUI

struct NullableDatePicker: View {

    // TODO: Localize ⤵️
    var title: String
    @Binding var selection: Date?

    init(_ title: String, selection: Binding<Date?>) {
        self.title = title
        self._selection = selection
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if selection == nil {
                notSetButton
            } else {
                datePicker
                clearButton
            }
        }
    }

    @ViewBuilder var notSetButton: some View {
        // TODO: Localize ⤵️
        Button("Not set") {
            selection = .now
        }
        .buttonStyle(.bordered)
    }

    @ViewBuilder var datePicker: some View {
        DatePicker(
            "",
            selection: Binding<Date>(
                get: { selection ?? .now },
                set: { selection = $0 }
            ),
            displayedComponents: .date
        )
        .labelsHidden()
        .datePickerStyle(.compact)
    }

    @ViewBuilder var clearButton: some View {
        // TODO: DRY ⤵️
        Button(role: .destructive) {
            selection = nil
        } label: {
            Text("button.label.clear", bundle: .module)
        }
        .buttonStyle(.bordered)
    }
}

// MARK: - Preview

#Preview {
    struct Preview: View {
        @State private var selection: Date?
        var body: some View {
            Form {
                Section {
                    NullableDatePicker("Due date", selection: $selection)
                }
            }
        }
    }
    return Preview()
}
