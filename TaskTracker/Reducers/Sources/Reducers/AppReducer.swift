import ComposableArchitecture
import Foundation
import Models
import Storage

@Reducer public struct AppReducer {

    @ObservableState public struct State: Equatable {
        @Shared(.todoStorage) public var todos: IdentifiedArrayOf<ToDo> = []
        @Presents public var todoForm: TodoFormReducer.State?

        public init() {}
    }

    public enum Action {
        case addTodoTapAction
        case todoFormAction(PresentationAction<TodoFormReducer.Action>)
        case saveTodoFormAction
        case deleteAction(IndexSet)
        case todoItemAction(IdentifiedActionOf<TodoItemReducer>)
        case titleTapAction(ToDo)
    }

    @Dependency(\.uuid) var uuid

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
            case .todoItemAction:
                return .none
            case .titleTapAction(let todo):
                return reduceTitleTap(state: &state, todo: todo)
            }
        }
        .ifLet(\.$todoForm, action: \.todoFormAction) {
            TodoFormReducer()
        }
        .forEach(\.todos, action: \.todoItemAction) {
            TodoItemReducer()
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
        state.todos[id: todoToSave.id] = todoToSave
        state.todoForm = nil
        return .none
    }

    private func reduceDelete(state: inout State, indexSet: IndexSet) -> Effect<Action> {
        state.todos.remove(atOffsets: indexSet)
        return .none
    }

    private func reduceTitleTap(state: inout State, todo: ToDo) -> Effect<Action> {
        state.todoForm = TodoFormReducer.State(todo: todo)
        return .none
    }
}
