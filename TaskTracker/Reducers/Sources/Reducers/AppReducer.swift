import ComposableArchitecture
import Foundation
import Models
import Storage

@Reducer public struct AppReducer {

    @ObservableState public struct State: Equatable {
        @Shared(.todos) public var todos: IdentifiedArrayOf<ToDo> = []
        @Presents public var addTodoForm: TodoFormReducer.State?

        public init() {}
    }

    public enum Action {
        case addTodoTapAction
        case addTodoFormAction(PresentationAction<TodoFormReducer.Action>)
        case confirmAddTodoAction
        case onDeleteAction(IndexSet)
        case todoItemAction(IdentifiedActionOf<TodoItemReducer>)
    }

    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addTodoTapAction:
                state.addTodoForm = TodoFormReducer.State(todo: ToDo(id: ToDo.ID(uuid()), title: ""))
                return .none
            case .addTodoFormAction:
                return .none
            case .confirmAddTodoAction:
                guard let addedTodo = state.addTodoForm?.todo else {
                    return .none
                }
                state.todos.append(addedTodo)
                state.addTodoForm = nil
                return .none
            case .onDeleteAction(let indexSet):
                state.todos.remove(atOffsets: indexSet)
                return .none
            case .todoItemAction:
                return .none
            }
        }
        .ifLet(\.$addTodoForm, action: \.addTodoFormAction) {
            TodoFormReducer()
        }
        .forEach(\.todos, action: \.todoItemAction) {
            TodoItemReducer()
        }
    }
}
