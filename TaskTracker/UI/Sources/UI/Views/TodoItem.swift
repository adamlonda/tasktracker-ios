import ComposableArchitecture
import Models
import Reducers
import SwiftUI

struct TodoItem: View {

    @Bindable var store: StoreOf<TodoItemReducer>
    var titleTapAction: (ToDo) -> Void

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
                .font(.system(size: 20))
                .lineLimit(1)
                .onTapGesture {
                    titleTapAction(store.state)
                }
        }
    }
}

#Preview {
    TodoItem(
        store: Store(
            initialState: .mock(title: "Hello Hello Hello Hello Hello Hello World 👋")
        ) {
            TodoItemReducer()
        },
        titleTapAction: { print("\($0.title) tapped") }
    )
}
