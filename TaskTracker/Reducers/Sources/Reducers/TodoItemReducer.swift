import ComposableArchitecture
import Models
import Tagged

@Reducer public struct TodoItemReducer {
    public typealias State = ToDo

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case toggleCompletionAction
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .toggleCompletionAction:
                state.isCompleted.toggle()
                return .none
            }
        }
    }
}
