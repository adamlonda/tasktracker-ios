import ComposableArchitecture
import Foundation
import Models
import Storage

@Reducer public struct AppReducer {

    @ObservableState public struct State: Equatable {
        @Shared(.todoStorage) public var storedTodos: IdentifiedArrayOf<ToDo> = []

        public var pendingTab = TabReducer.State(.pending)
        public var completedTab = TabReducer.State(.completed)
        public var allTab = TabReducer.State(.all)

        public var selectedTab: Tab = .pending
        @Presents public var todoForm: TodoFormReducer.State?

        public init() {}
    }

    public enum Action {
        case addTodoTapAction
        case selectedTabChangedAction(Tab)
        case pendingTabAction(TabReducer.Action)
        case completedTabAction(TabReducer.Action)
        case allTabAction(TabReducer.Action)
        case todoFormAction(PresentationAction<TodoFormReducer.Action>)
    }

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
            case .pendingTabAction:
                return .none
            case .completedTabAction(let tabAction):
                return reduceCompletedTab(state: &state, tabAction: tabAction)
            case .allTabAction:
                return .none
            case .todoFormAction(let formAction):
                return reduceSaveTodoForm(state: &state, formAction: formAction)
            }
        }
        .ifLet(\.$todoForm, action: \.todoFormAction) {
            TodoFormReducer()
        }
        Scope(state: \.pendingTab, action: /Action.pendingTabAction) {
            TabReducer()
        }
        Scope(state: \.completedTab, action: /Action.completedTabAction) {
            TabReducer()
        }
        Scope(state: \.allTab, action: /Action.allTabAction) {
            TabReducer()
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

    private func reduceCompletedTab(state: inout State, tabAction: TabReducer.Action) -> Effect<Action> {
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
        guard let todoToSave = state.todoForm?.todo else {
            return .none
        }
        state.storedTodos[id: todoToSave.id] = todoToSave
        state.todoForm = nil
        return .none
    }
}
