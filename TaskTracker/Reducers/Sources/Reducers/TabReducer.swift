import ComposableArchitecture
import Foundation
import Models

@Reducer public struct TabReducer {

    @ObservableState public struct State: Equatable {
        @Shared(.todoStorage) public var storedTodos: IdentifiedArrayOf<ToDo> = []
        public var displayedTodos: IdentifiedArrayOf<ToDo> = []

        @Presents public var todoForm: TodoFormReducer.State?
        public let tab: Tab

        public init(_ tab: Tab) {
            self.tab = tab
            updateDisplayedTodos()
        }

        fileprivate mutating func updateDisplayedTodos() {
            var filtered = tab.filteredTodos(from: storedTodos)
            filtered.sort(by: >)
            displayedTodos = filtered
        }
    }

    public enum Delegate: Equatable {
        case switchToPendingTab
    }

    public enum Action: Equatable {
        case addTodoTapAction
        case deleteAction(IndexSet)
        case todoFormAction(PresentationAction<TodoFormReducer.Action>)
        case todoItemAction(IdentifiedActionOf<TodoItemReducer>)
        case delegate(Delegate)
        case onAppearAction
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
            case .deleteAction(let indexSet):
                return reduceDelete(state: &state, indexSet: indexSet)
            case .todoFormAction(let formAction):
                return reduceSaveTodoForm(state: &state, formAction: formAction)
            case .todoItemAction(let action):
                return reduceTodoItem(state: &state, action: action)
            case .delegate:
                return .none
            case .onAppearAction:
                return reduceOnAppear(state: &state)
            }
        }
        .ifLet(\.$todoForm, action: \.todoFormAction) {
            TodoFormReducer()
        }
        .forEach(\.displayedTodos, action: \.todoItemAction) {
            TodoItemReducer()
                .dependency(\.date, date)
        }
    }

    // MARK: - Reduce Methods

    private func reduceAddTodoTap(state: inout State) -> Effect<Action> {
        state.todoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(uuid()), title: ""))
        return .none
    }

    private func reduceDelete(state: inout State, indexSet: IndexSet) -> Effect<Action> {
        for index in indexSet {
            state.storedTodos.remove(id: state.displayedTodos[index].id)
        }
        state.updateDisplayedTodos()
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

        let addingNewTodo = state.storedTodos.contains { $0.id == todoToSave.id } == false
        state.storedTodos[id: todoToSave.id] = todoToSave
        state.todoForm = nil

        if addingNewTodo && state.tab == .completed {
            return .send(.delegate(.switchToPendingTab))
        } else {
            state.updateDisplayedTodos()
            return .none
        }
    }

    private func reduceTodoItem(state: inout State, action: IdentifiedActionOf<TodoItemReducer>) -> Effect<Action> {
        switch action {
        case .element(let id, let elementAction):
            if case .toggleCompletionAction = elementAction {
                state.storedTodos[id: id] = state.displayedTodos[id: id]
                state.updateDisplayedTodos()
            } else if case .tapAction = elementAction {
                if let todoToEdit = state.storedTodos[id: id] {
                    state.todoForm = TodoFormReducer.State(todo: todoToEdit)
                }
            }
        }
        return .none
    }

    private func reduceOnAppear(state: inout State) -> Effect<Action> {
        state.updateDisplayedTodos()
        return .none
    }
}
