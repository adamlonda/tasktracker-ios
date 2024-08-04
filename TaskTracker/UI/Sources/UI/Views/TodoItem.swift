import ComposableArchitecture
import Models
import Reducers
import SwiftUI

struct TodoItem: View {

    @Bindable var store: StoreOf<TodoItemReducer>

    var body: some View {
        HStack(alignment: .center, spacing: .medium) {
            Button {
                store.send(.toggleCompletionAction)
            } label: {
                Image(systemName: store.completedAt == nil ? "circle" : "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            Text(store.title)
                .font(.system(size: 20))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.listItemBackground)
                .onTapGesture {
                    store.send(.tapAction)
                }
            Image(systemName: store.priority.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(store.priority.color)
                .background(Color.listItemBackground)
                .onTapGesture {
                    store.send(.tapAction)
                }
        }
    }
}

// MARK: - Previews

extension TodoItem {
    fileprivate static func preview(_ todo: ToDo) -> some View {
        TodoItem(
            store: Store(initialState: todo) {
                TodoItemReducer()
            }
        )
        .background(Color.listItemBackground)
    }
}

#Preview("Normal") {
    TodoItem.preview(.mock(title: "Hello World 👋"))
}

#Preview("Low") {
    TodoItem.preview(.mock(title: "Hello World 👋", priority: .low))
}

#Preview("High") {
    TodoItem.preview(.mock(title: "Hello World 👋", priority: .high))
}

#Preview("Long Title") {
    TodoItem.preview(.mock(title: "Hello Hello Hello Hello Hello Hello World 👋"))
}
