import ComposableArchitecture
import Models
import Reducers
import SwiftUI

// TODO: Hardcoded number constants 🧹
public struct AppView: View {

    @Bindable var store: StoreOf<AppReducer>

    // MARK: - Body

    public var body: some View {
        if store.state.storedTodos.isEmpty {
            emptyView
                .sheet(
                    item: $store.scope(state: \.todoForm, action: \.todoFormAction)
                ) { todoFormStore in
                    NavigationStack {
                        TodoForm(store: todoFormStore)
                    }
                }
        } else {
            tabView
        }
    }

    // MARK: - Empty View

    @ViewBuilder var emptyView: some View {
        VStack(alignment: .center, spacing: .large) {
            Text("text.no_tasks_yet", bundle: .module)
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
                        Text("button.text.add_first_task", bundle: .module)
                    }
                }
            )
        }
        .padding(.horizontal, .medium)
    }

    // MARK: - Tabs View

    @ViewBuilder var tabView: some View {
        WithViewStore(self.store, observe: \.selectedTab) { viewStore in
            TabView(
                selection: viewStore.binding(send: AppReducer.Action.selectedTabChangedAction)
            ) {
                todayTab
                thingsToDoTab
                completedTab
                allTodosTab
                trashBinTab
            }
        }
    }

    // MARK: - Today Tab

    @ViewBuilder var todayTab: some View {
        TodoListTabView(store: store.scope(state: \.todayTab, action: \.todayTabAction))
            .tabItem {
                Image(systemName: "calendar")
                Text("tab.text.today", bundle: .module)
            }
            .tag(Tab.today)
    }

    // MARK: - Pending Tab

    @ViewBuilder var thingsToDoTab: some View {
        TodoListTabView(store: store.scope(state: \.pendingTab, action: \.pendingTabAction))
            .tabItem {
                Image(systemName: "tray")
                Text("tab.text.todo", bundle: .module)
            }
            .tag(Tab.pending)
    }

    // MARK: - Completed Tab

    @ViewBuilder var completedTab: some View {
        TodoListTabView(store: store.scope(state: \.completedTab, action: \.completedTabAction))
            .tabItem {
                Image(systemName: "checkmark.circle")
                Text("tab.text.done", bundle: .module)
            }
            .tag(Tab.completed)
    }

    // MARK: - All Todos Tab

    @ViewBuilder var allTodosTab: some View {
        TodoListTabView(store: store.scope(state: \.allTab, action: \.allTabAction))
            .tabItem {
                Image(systemName: "list.bullet")
                Text("tab.text.all", bundle: .module)
            }
            .tag(Tab.all)
    }

    @ViewBuilder var trashBinTab: some View {
        TodoListTabView(store: store.scope(state: \.trashBinTab, action: \.trashBinTabAction))
            .tabItem {
                Image(systemName: "trash")
                Text("tab.text.trash", bundle: .module)
            }
            .tag(Tab.trashBin)
    }

    // MARK: - Init

    public init(store: StoreOf<AppReducer>) {
        self._store = Bindable(store)
    }
}

// MARK: - Previews

#Preview("Empty") {
    WithInMemory { userDefaults in
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = []
        AppView(
            store: Store(
                initialState: AppReducer.State()
            ) {
                AppReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}

#Preview("Non-empty") {
    WithInMemory { userDefaults in
        let now = Date.now
        @Shared(.todoStorage(store: userDefaults)) var todos: IdentifiedArrayOf<ToDo> = [
            .twoDaysOverdue(from: now, title: "First todo"),
            .dueYesterday(from: now, title: "Second todo"),
            .mock(title: "Third todo very very very long", dueDate: now),
            .dueTomorrow(from: now, title: "Fourth todo"),
            .dueThisWeek(from: now, title: "Fifth todo"),
            .dueNextWeek(from: now, title: "Sixth todo"),
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
        AppView(
            store: Store(
                initialState: AppReducer.State()
            ) {
                AppReducer()
            } withDependencies: {
                $0.defaultAppStorage = userDefaults
            }
        )
    }
}
