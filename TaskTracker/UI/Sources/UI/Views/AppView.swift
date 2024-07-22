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
            List {
                ForEach(store.scope(state: \.todos, action: \.todoItemAction)) { store in
                    TodoItem(store: store)
                }
                .onDelete { indexSet in
                    store.send(.onDeleteAction(indexSet))
                }
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
        .mock(title: "Second todo very very very long"),
        .mock(title: "Third todo"),
        .mock(title: "Fourth todo"),
        .mock(title: "Fifth todo"),
        .mock(title: "Sixth todo"),
        .mock(title: "Seventh todo"),
        .mock(title: "Eighth todo"),
        .mock(title: "Ninth todo"),
        .mock(title: "Tenth todo"),
        .mock(title: "Eleventh todo"),
        .mock(title: "Twelfth todo"),
        .mock(title: "Thirteenth todo"),
        .mock(title: "Fourteenth todo"),
        .mock(title: "Fifteenth todo"),
        .mock(title: "Sixteenth todo"),
        .mock(title: "Seventeenth todo"),
        .mock(title: "Eighteenth todo"),
        .mock(title: "Nineteenth todo"),
        .mock(title: "Twentieth todo")
    ]

    return AppView(
        store: Store(
            initialState: AppReducer.State()
        ) {
            AppReducer()
        }
    )
}
