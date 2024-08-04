import ComposableArchitecture
import Models
import Reducers
import SwiftUI

struct TodoListTabView: View {

    @Bindable var store: StoreOf<TabReducer>

    // MARK: - Body

    var body: some View {
        NavigationView {
            content
                .onAppear { store.send(.onAppearAction) }
                .sheet(
                    item: $store.scope(state: \.todoForm, action: \.todoFormAction)
                ) { todoFormStore in
                    NavigationStack {
                        TodoForm(store: todoFormStore)
                    }
                }
                .navigationTitle(store.state.tab.title)
                .navigationBarItems(
                    trailing: Button(
                        action: { store.send(.addTodoTapAction) },
                        label: {
                            Image(systemName: "plus")
                        }
                    )
                )
        }
    }

    @ViewBuilder var content: some View {
        if store.state.displayedTodos.isEmpty {
            emptyView
        } else {
            listView
        }
    }

    // MARK: - Empty View

    @ViewBuilder var emptyView: some View {
        VStack(alignment: .center, spacing: .large) {
            Image(systemName: store.state.tab.emptyImageName)
                .resizable()
                .foregroundColor(store.state.tab.emptyImageColor)
                .scaledToFit()
                .frame(width: 80, height: 80)
            Text(store.state.tab.emptyText)
                .font(.title2)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, .large)
    }

    // MARK: - List

    @ViewBuilder var listView: some View {
        List {
            ForEach(store.scope(state: \.displayedTodos, action: \.todoItemAction)) { todoItemStore in
                TodoItem(store: todoItemStore)
            }
            .onDelete { indexSet in
                store.send(.deleteAction(indexSet))
            }
        }
    }
}

// MARK: - Tab UI Extensions

extension Tab {
    fileprivate var title: String {
        switch self {
        case .pending:
            return "Things to do"
        case .completed:
            return "Already done"
        case .all:
            return "To do & Done"
        }
    }

    fileprivate var emptyImageName: String {
        switch self {
        case .pending:
            return "checkmark.rectangle.stack.fill"
        case .completed:
            return "tray.fill"
        case .all:
            return ""
        }
    }

    fileprivate var emptyImageColor: Color {
        switch self {
        case .pending:
            return .green
        case .completed:
            return .blue
        case .all:
            return .clear
        }
    }

    fileprivate var emptyText: String {
        switch self {
        case .pending:
            return "Seems like everything is done here."
        case .completed:
            return "Seems like nothing is done, yet."
        case .all:
            return ""
        }
    }
}

// MARK: - Previews

#Preview("To Do") {
    @Shared(.todoStorage) var todos = [
        .mock(title: "First todo"),
        .mock(title: "Third todo")
    ]
    return TodoListTabView(
        store: Store(
            initialState: TabReducer.State(.pending)
        ) {
            TabReducer()
        }
    )
}

#Preview("Empty To Do") {
    TodoListTabView(
        store: Store(
            initialState: TabReducer.State(.pending)
        ) {
            TabReducer()
        }
    )
}

#Preview("Done") {
    @Shared(.todoStorage) var todos = [
        .mock(title: "Second todo", completedAt: .now),
        .mock(title: "Fourth todo", completedAt: .now)
    ]
    return TodoListTabView(
        store: Store(
            initialState: TabReducer.State(.completed)
        ) {
            TabReducer()
        }
    )
}

#Preview("Empty Done") {
    TodoListTabView(
        store: Store(
            initialState: TabReducer.State(.completed)
        ) {
            TabReducer()
        }
    )
}

#Preview("To Do & Done") {
    @Shared(.todoStorage) var todos = [
        .mock(title: "First todo"),
        .mock(title: "Second todo", completedAt: .now),
        .mock(title: "Third todo"),
        .mock(title: "Fourth todo", completedAt: .now)
    ]
    return TodoListTabView(
        store: Store(
            initialState: TabReducer.State(.all)
        ) {
            TabReducer()
        }
    )
}
