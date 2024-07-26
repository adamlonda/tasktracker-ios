import ComposableArchitecture
import Models
import Reducers
import SwiftUI

struct ListWithNavigationBar: View {

    @Bindable var store: StoreOf<AppReducer>

    var todoItemTitleTapAction: (ToDo) -> Void
    var onDeleteAction: (IndexSet) -> Void
    var addTodoTapAction: () -> Void

    // MARK: - Body

    var body: some View {
        NavigationView {
            content
                .navigationTitle(store.state.selectedTab.title)
                .navigationBarItems(
                    trailing: Button(
                        action: addTodoTapAction,
                        label: {
                            Image(systemName: "plus")
                        }
                    )
                )
        }
    }

    @ViewBuilder var content: some View {
        if store.state.filteredTodos.isEmpty {
            emptyView
        } else {
            list
        }
    }

    // MARK: - Empty View

    @ViewBuilder var emptyView: some View {
        VStack(alignment: .center, spacing: .large) {
            Image(systemName: store.selectedTab.emptyImageName)
                .resizable()
                .foregroundColor(store.selectedTab.emptyImageColor)
                .scaledToFit()
                .frame(width: 80, height: 80)
            Text(store.selectedTab.emptyText)
                .font(.title2)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, .large)
    }

    // MARK: - List

    @ViewBuilder var list: some View {
        List {
            ForEach(store.scope(state: \.filteredTodos, action: \.todoItemAction)) { todoItemStore in
                TodoItem(
                    store: todoItemStore,
                    titleTapAction: todoItemTitleTapAction
                )
            }
            .onDelete { indexSet in
                onDeleteAction(indexSet)
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

// MARK: - Previews DRY

extension ListWithNavigationBar {
    fileprivate init(store: StoreOf<AppReducer>) {
        self.store = store
        self.todoItemTitleTapAction = { print("\($0.title) tapped") }
        self.onDeleteAction = { _ in }
        self.addTodoTapAction = { print("Add button tapped") }
    }
}

extension StoreOf<AppReducer> {
    fileprivate static func store(
        for tab: Tab,
        with givenTodos: IdentifiedArrayOf<ToDo> = []
    ) -> StoreOf<AppReducer> {
        @Shared(.todoStorage) var todos = givenTodos
        let store = Store(
            initialState: AppReducer.State()
        ) {
            AppReducer()
        }
        store.send(.selectedTabChangedAction(tab))
        return store
    }
}

// MARK: - Previews

#Preview("To Do") {
    ListWithNavigationBar(
        store: .store(
            for: .pending,
            with: [
                .mock(title: "First todo"),
                .mock(title: "Third todo")
            ]
        )
    )
}

#Preview("Empty To Do") {
    ListWithNavigationBar(store: .store(for: .pending))
}

#Preview("Done") {
    ListWithNavigationBar(
        store: .store(
            for: .completed,
            with: [
                .mock(title: "Second todo", isCompleted: true),
                .mock(title: "Fourth todo", isCompleted: true)
            ]
        )
    )
}

#Preview("Empty Done") {
    ListWithNavigationBar(store: .store(for: .completed))
}

#Preview("To Do & Done") {
    ListWithNavigationBar(
        store: .store(
            for: .all,
            with: [
                .mock(title: "First todo"),
                .mock(title: "Second todo", isCompleted: true),
                .mock(title: "Third todo"),
                .mock(title: "Fourth todo", isCompleted: true)
            ]
        )
    )
}
