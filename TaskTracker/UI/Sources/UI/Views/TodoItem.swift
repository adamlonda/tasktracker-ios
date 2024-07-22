import ComposableArchitecture
import Reducers
import SwiftUI

struct TodoItem: View {

    @Bindable var store: StoreOf<TodoItemReducer>

    var body: some View {
        HStack(alignment: .center, spacing: .medium) {
            Button {
                store.send(.toggleCompletionAction)
            } label: {
                Image(systemName: store.isCompleted ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            Text(store.title)
                .font(.title3)
                .lineLimit(1)
        }
    }
}

#Preview {
    TodoItem(
        store: Store(
            initialState: .mock(title: "Hello Hello Hello Hello Hello Hello World 👋")
        ) {
            TodoItemReducer()
        }
    )
}
