import ComposableArchitecture
import Models

@Reducer public struct TodoFormReducer {

    public enum Field: Hashable {
        case title
    }

    @ObservableState public struct State: Equatable {
        public var todo: ToDo
        public var focus: Field? = .title
        public var isSaveDisabled: Bool = true

        public init(todo: ToDo) {
            self.todo = todo
        }
    }

    public enum Delegate: Equatable {
        case save
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case saveAction
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                state.isSaveDisabled = state.todo.title.isEmpty
                return .none
            case .delegate:
                return .none
            case .saveAction:
                return .send(.delegate(.save))
            }
        }
    }
}
