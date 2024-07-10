import ComposableArchitecture
import ModelsMocks
import Reducers
import SwiftUI

struct TodoForm: View {

    @Bindable var store: StoreOf<TodoFormReducer>
    @FocusState var focus: TodoFormReducer.Field?
    var saveAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            form
            saveButton
        }
        .bind($store.focus, to: $focus)
    }

    @ViewBuilder var form: some View {
        Form {
            Section {
                TextField("What's this will be about?", text: $store.todo.title)
                    .focused($focus, equals: .title)
            } header: {
                Text("Summary")
            }

            Section {
                TextField("Need anything further to note?", text: $store.todo.note, axis: .vertical)
                    .lineLimit(13, reservesSpace: true)
            } header: {
                Text("Notes")
            }
        }
    }

    @ViewBuilder var saveButton: some View {
        Button {
            saveAction()
        } label: {
            HStack {
                Image(systemName: "checkmark")
                Text("Save")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .padding(.horizontal, .large)
        .padding(.bottom, .medium)
        .disabled(store.isSaveDisabled)
    }
}

#Preview {
    TodoForm(
        store: Store(
            initialState: TodoFormReducer.State(todo: .new)
        ) {
            TodoFormReducer()
        },
        saveAction: {}
    )
}
