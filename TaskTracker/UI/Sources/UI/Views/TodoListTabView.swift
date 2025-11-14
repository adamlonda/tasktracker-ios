import ComposableArchitecture
import Models
import Reducers
import SwiftUI

struct TodoListTabView: View {

    @Bindable var store: StoreOf<TodoListTabReducer>

    // MARK: - Body

    var body: some View {
        NavigationView {
            content
                .onAppear { store.send(.onAppearAction) }
                .alert($store.scope(state: \.alert, action: \.alertAction))
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
            if store.state.tab == .trashBin {
                forEachTrashBin
            } else {
                forEachTodo
            }
        }
    }

    @ViewBuilder var forEachTodo: some View {
        ForEach(store.scope(state: \.displayedTodos, action: \.todoItemAction)) { todoItemStore in
            TodoItem(store: todoItemStore)
                .contextMenu {
                    Button(role: .destructive) {
                        store.send(.moveToTrashAction(todoItemStore.id))
                    } label: {
                        Label("Move to trash", systemImage: "trash")
                    }
                }
        }
    }

    @ViewBuilder var forEachTrashBin: some View {
        ForEach(store.scope(state: \.displayedTodos, action: \.todoItemAction)) { todoItemStore in
            TodoItem(store: todoItemStore)
                .contextMenu {
                    Button {
                        store.send(.moveFromTrashAction(todoItemStore.id))
                    } label: {
                        Label("Restore", systemImage: "arrow.uturn.backward")
                    }
                    Button(role: .destructive) {
                        store.send(.deleteAction(todoItemStore.id))
                    } label: {
                        Label("Delete permanently", systemImage: "xmark.bin")
                    }
                }
        }
    }
}

// MARK: - Tab UI Extensions

extension Models.Tab {
    fileprivate var title: String {
        switch self {
        case .pending:
            return "Things to do"
        case .completed:
            return "Already done"
        case .all:
            return "To do & Done"
        case .today:
            return "To do today"
        case .trashBin:
            return "Trash bin"
        }
    }

    fileprivate var emptyImageName: String {
        switch self {
        case .pending:
            return "checkmark.rectangle.stack.fill"
        case .completed:
            return "tray.fill"
        case .all:
            return "tray.2.fill"
        case .today:
            return "calendar.badge.checkmark"
        case .trashBin:
            return "trash.slash.fill"
        }
    }

    fileprivate var emptyImageColor: Color? {
        switch self {
        case .pending:
            return .green
        case .completed:
            return .accentColor
        case .all:
            return .accentColor
        case .today:
            return .green
        case .trashBin:
            return .primary
        }
    }

    fileprivate var emptyText: String {
        switch self {
        case .pending:
            return "Seems like everything is done here."
        case .completed:
            return "Seems like nothing is done, yet."
        case .all:
            return "No tasks to display here, right now."
        case .today:
            return "Seems like nothing is scheduled for today, yet."
        case .trashBin:
            return "Seems like trash bin is empty, for now."
        }
    }
}

// MARK: - Previews

#Preview("Today") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = [
            .mock(title: "First todo", dueDate: .now),
            .mock(title: "Second todo", dueDate: .now)
        ]
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.today)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("Empty Today") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = []
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.today)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("To Do") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = [
            .mock(title: "First todo"),
            .mock(title: "Second todo")
        ]
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.pending)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("Empty To Do") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = []
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.pending)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("Done") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = [
            .mock(title: "Second todo", completedAt: .now),
            .mock(title: "Fourth todo", completedAt: .now)
        ]
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.completed)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("Empty Done") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = []
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.completed)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("To Do & Done") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = [
            .mock(title: "First todo"),
            .mock(title: "Second todo", completedAt: .now),
            .mock(title: "Third todo"),
            .mock(title: "Fourth todo", completedAt: .now)
        ]
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.all)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("Empty To Do & Done") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = []
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.all)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("Bin") {
    WithInMemory { userDefaults in
        let now = Date.now
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = [
            .mock(title: "Two seconds ago", trashedAt: .twoSecondsAgo(from: now)),
            .mock(title: "Second ago", trashedAt: .secondAgo(from: now)),
            .mock(title: "Now", trashedAt: now)
        ]
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.trashBin)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("Empty Bin") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = []
        TodoListTabView(
            store: Store(
                initialState: TodoListTabReducer.State(.trashBin)
            ) {
                TodoListTabReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}
