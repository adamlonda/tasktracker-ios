import ComposableArchitecture
import Models
import Reducers
import SwiftUI

public struct AppView: View {

    @Bindable var store: StoreOf<AppReducer>

    // MARK: - Body

    public var body: some View {
        content
            .sheet(item: $store.scope(state: \.todoForm, action: \.todoFormAction)) { todoFormStore in
                NavigationStack {
                    TodoForm(
                        store: todoFormStore,
                        saveAction: { store.send(.saveTodoFormAction) }
                    )
                }
            }
    }

    @ViewBuilder var content: some View {
        if store.state.storedTodos.isEmpty {
            emptyView
        } else {
            tabView
        }
    }

    // MARK: - Empty View

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

    // MARK: - Tabs & List View

    @ViewBuilder var tabView: some View {
        WithViewStore(self.store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(send: AppReducer.Action.selectedTabChangedAction)) {
                thingsToDoTab
                completedTab
                allTodosTab
            }
        }
    }

    @ViewBuilder var listWithNavigationBar: some View {
        ListWithNavigationBar(
            store: store,
            todoItemTitleTapAction: {
                store.send(.titleTapAction($0))
            },
            onDeleteAction: { indexSet in
                store.send(.deleteAction(indexSet))
            },
            addTodoTapAction: {
                store.send(.addTodoTapAction)
            }
        )
    }

    // MARK: - Pending Tab

    @ViewBuilder var thingsToDoTab: some View {
        listWithNavigationBar
            .tabItem {
                Image(systemName: "tray")
                Text("To Do")
            }
            .tag(Tab.pending)
    }

    // MARK: - Completed Tab

    @ViewBuilder var completedTab: some View {
        listWithNavigationBar
            .tabItem {
                Image(systemName: "checkmark.circle")
                Text("Done")
            }
            .tag(Tab.completed)
    }

    // MARK: - All Todos Tab

    @ViewBuilder var allTodosTab: some View {
        listWithNavigationBar
            .tabItem {
                Image(systemName: "list.bullet")
                Text("All")
            }
            .tag(Tab.all)
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
    @Shared(.todoStorage) var todos = [
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
