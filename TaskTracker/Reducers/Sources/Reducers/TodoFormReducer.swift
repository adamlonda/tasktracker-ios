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

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                state.isSaveDisabled = state.todo.title.isEmpty
                return .none
            }
        }
    }
}
