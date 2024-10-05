import ComposableArchitecture
import Foundation
import Models
import Storage

@Reducer public struct AppReducer {

    @ObservableState public struct State: Equatable {
        @Shared(.todoStorage) public var storedTodos: IdentifiedArrayOf<ToDo> = []

        public var todayTab = TodoListTabReducer.State(.today)
        public var pendingTab = TodoListTabReducer.State(.pending)
        public var completedTab = TodoListTabReducer.State(.completed)
        public var allTab = TodoListTabReducer.State(.all)

        public var selectedTab: Tab = .today
        @Presents public var todoForm: TodoFormReducer.State?

        public init() {}
    }

    public enum Action {
        case addTodoTapAction
        case selectedTabChangedAction(Tab)
        case todayTabAction(TodoListTabReducer.Action)
        case pendingTabAction(TodoListTabReducer.Action)
        case completedTabAction(TodoListTabReducer.Action)
        case allTabAction(TodoListTabReducer.Action)
        case todoFormAction(PresentationAction<TodoFormReducer.Action>)
    }

    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addTodoTapAction:
                return reduceAddTodoTap(state: &state)
            case .selectedTabChangedAction(let tab):
                return reduceSelectedTabChanged(state: &state, tab: tab)
            case .todayTabAction(let tabAction):
                return reduceSwitchToPendingTab(state: &state, tabAction: tabAction)
            case .pendingTabAction:
                return .none
            case .completedTabAction(let tabAction):
                return reduceSwitchToPendingTab(state: &state, tabAction: tabAction)
            case .allTabAction:
                return .none
            case .todoFormAction(let formAction):
                return reduceSaveTodoForm(state: &state, formAction: formAction)
            }
        }
        .ifLet(\.$todoForm, action: \.todoFormAction) {
            TodoFormReducer()
        }
        Scope(state: \.todayTab, action: \.todayTabAction) {
            TodoListTabReducer()
        }
        Scope(state: \.pendingTab, action: \.pendingTabAction) {
            TodoListTabReducer()
        }
        Scope(state: \.completedTab, action: \.completedTabAction) {
            TodoListTabReducer()
        }
        Scope(state: \.allTab, action: \.allTabAction) {
            TodoListTabReducer()
        }
    }

    // MARK: - Reduce Methods

    private func reduceAddTodoTap(state: inout State) -> Effect<Action> {
        state.todoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(uuid()), title: ""))
        return .none
    }

    private func reduceSelectedTabChanged(state: inout State, tab: Tab) -> Effect<Action> {
        state.selectedTab = tab
        return .none
    }

    private func reduceSwitchToPendingTab(state: inout State, tabAction: TodoListTabReducer.Action) -> Effect<Action> {
        if case .delegate(.switchToPendingTab) = tabAction {
            state.selectedTab = .pending
        }
        return .none
    }

    private func reduceSaveTodoForm(
        state: inout State,
        formAction: PresentationAction<TodoFormReducer.Action>
    ) -> Effect<Action> {
        guard case .presented(.delegate(.save)) = formAction else {
            return .none
        }
        guard var todoToSave = state.todoForm?.todo else {
            return .none
        }
        let trimmedDueDate = todoToSave.dueDate?.trim(with: calendar)
        todoToSave.dueDate = trimmedDueDate
        state.storedTodos[id: todoToSave.id] = todoToSave

        state.todoForm = nil
        state.selectedTab = todoToSave.isListedFor(today: date.now, by: calendar) ? .today : .pending

        return .none
    }
}
