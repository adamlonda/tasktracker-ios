import ComposableArchitecture
import Foundation
import Models
import Storage

@Reducer public struct AppReducer {

    @ObservableState public struct State: Equatable {
        @Shared(.todoStorage) public var storedTodos: IdentifiedArrayOf<ToDo> = []
        public var displayedTodos: IdentifiedArrayOf<ToDo> = []

        public var selectedTab: Tab
        public var pendingTab = PendingTabReducer.State()
        public var completedTab = CompletedTabReducer.State()
        public var allTab = AllTabReducer.State()

        @Presents public var todoForm: TodoFormReducer.State?

        public init() {
            self.selectedTab = .pending
            self.updateDisplayedTodos()
        }

        private mutating func updateDisplayedTodos() {
            displayedTodos = selectedTab.displayedTodos(from: storedTodos)
        }
    }

    public enum Action {
        case addTodoTapAction
        case todoFormAction(PresentationAction<TodoFormReducer.Action>)
        case saveTodoFormAction
        case deleteAction(IndexSet)
        case todoItemAction(IdentifiedActionOf<TodoItemReducer>)
        case todoTapAction(ToDo)

        case selectedTabChangedAction(Tab)
        case pendingTabAction(PendingTabReducer.Action)
        case completedTabAction(CompletedTabReducer.Action)
        case allTabAction(AllTabReducer.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addTodoTapAction:
                return reduceAddTodoTap(state: &state)
            case .todoFormAction:
                return .none
            case .saveTodoFormAction:
                return reduceSaveTodoForm(state: &state)
            case .deleteAction(let indexSet):
                return reduceDelete(state: &state, indexSet: indexSet)
            case .todoItemAction(let action):
                return reduceTodoItem(state: &state, action: action)
            case .todoTapAction(let todo):
                return reduceTodoTap(state: &state, todo: todo)
            case .selectedTabChangedAction(let tab):
                return reduceSelectedTabChanged(state: &state, tab: tab)
            }
        }
        .ifLet(\.$todoForm, action: \.todoFormAction) {
            TodoFormReducer()
        }
        .forEach(\.displayedTodos, action: \.todoItemAction) {
            TodoItemReducer()
                .dependency(\.date, date)
        }
        Scope(state: \.pendingTab, action: /Action.pendingTabAction) {
            PendingTabReducer()
        }
        Scope(state: \.completedTab, action: /Action.completedTabAction) {
            CompletedTabReducer()
        }
        Scope(state: \.allTab, action: /Action.allTabAction) {
            AllTabReducer()
        }
    }

    // MARK: - Reduce Methods

    private func reduceAddTodoTap(state: inout State) -> Effect<Action> {
        state.todoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(uuid()), title: ""))
        return .none
    }

    private func reduceSaveTodoForm(state: inout State) -> Effect<Action> {
        guard let todoToSave = state.todoForm?.todo else {
            return .none
        }

        let addingNewTodo = state.storedTodos.contains { $0.id == todoToSave.id } == false
        state.storedTodos[id: todoToSave.id] = todoToSave

        if addingNewTodo && state.selectedTab == .completed {
            state.selectedTab = .pending
        }
        updateDisplayedTodos(on: &state, for: state.selectedTab)

        state.todoForm = nil
        return .none
    }

    private func reduceDelete(state: inout State, indexSet: IndexSet) -> Effect<Action> {
        for index in indexSet {
            state.storedTodos.remove(id: state.displayedTodos[index].id)
        }
        updateDisplayedTodos(on: &state, for: state.selectedTab)
        return .none
    }

    private func reduceTodoTap(state: inout State, todo: ToDo) -> Effect<Action> {
        state.todoForm = TodoFormReducer.State(todo: todo)
        return .none
    }

    private func reduceSelectedTabChanged(state: inout State, tab: Tab) -> Effect<Action> {
        state.selectedTab = tab
        updateDisplayedTodos(on: &state, for: tab)
        return .none
    }

    private func reduceTodoItem(state: inout State, action: IdentifiedActionOf<TodoItemReducer>) -> Effect<Action> {
        switch action {
        case .element(let id, let action):
            if case .toggleCompletionAction = action {
                state.storedTodos[id: id] = state.displayedTodos[id: id]
                updateDisplayedTodos(on: &state, for: state.selectedTab)
            }
        }
        return .none
    }

    // MARK: - DRY Methods

    private func updateDisplayedTodos(on state: inout State, for tab: Tab) {
        state.displayedTodos = tab.displayedTodos(from: state.storedTodos)
    }
}

extension Tab {
    fileprivate func displayedTodos(from allTodos: IdentifiedArrayOf<ToDo>) -> IdentifiedArrayOf<ToDo> {
        #warning("TODO: implement sorting as well 🚧")
        switch self {
        case .all:
            return allTodos
        case .pending:
            return allTodos.filter { $0.completedAt == nil }
        case .completed:
            return allTodos.filter { $0.completedAt != nil }
        }
    }
}
