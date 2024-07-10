import ComposableArchitecture
import Reducers
import SwiftUI

public struct AppView: View {

    @Bindable var store: StoreOf<AppReducer>

    // MARK: - Body

    public var body: some View {
        content
            .sheet(item: $store.scope(state: \.addTodoForm, action: \.addTodoFormAction)) { addTodoStore in
                NavigationStack {
                    TodoForm(
                        store: addTodoStore,
                        saveAction: { store.send(.confirmAddTodoAction) }
                    )
                }
            }
    }

    @ViewBuilder var content: some View {
        if store.state.todos.isEmpty {
            emptyView
        } else {
            listView
        }
    }

    // MARK: - Subviews

    @ViewBuilder var emptyView: some View {
        VStack(alignment: .center, spacing: .large) {
            Text("You haven't added any tasks yet. Why don't you add some now?")
                .font(.title2)
                .multilineTextAlignment(.center)
            Button(
                action: {
                    store.send(.addTodoTapAction)
                }, label: {
                    VStack(alignment: .center, spacing: .medium) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                        Text("Add my first task")
                    }
                }
            )
        }
        .padding(.horizontal, .medium)
    }

    @ViewBuilder var listView: some View {
        NavigationView {
            List(store.state.todos, id: \.id.rawValue) { todo in
                Text(todo.title)
            }
            .navigationTitle("Things to do")
            .navigationBarItems(
                trailing: Button(
                    action: {
                        store.send(.addTodoTapAction)
                    }, label: {
                        Image(systemName: "plus")
                    }
                )
            )
        }
    }

    // MARK: - Init

    public init(store: StoreOf<AppReducer>) {
        self._store = Bindable(store)
    }
}

// MARK: - Previews

#Preview("Empty") {
    AppView(
        store: Store(
            initialState: AppReducer.State()
        ) {
            AppReducer()
        }
    )
}

#Preview("Non-empty") {
    @Shared(.todos) var todos = [
        .mock(title: "First todo"),
        .mock(title: "Second todo"),
        .mock(title: "Third todo")
    ]

    return AppView(
        store: Store(
            initialState: AppReducer.State()
        ) {
            AppReducer()
        }
    )
}
