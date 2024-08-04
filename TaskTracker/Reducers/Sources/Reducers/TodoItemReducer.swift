import ComposableArchitecture
import Models
import Tagged

@Reducer public struct TodoItemReducer {
    public typealias State = ToDo

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case toggleCompletionAction
        case tapAction
    }

    @Dependency(\.date) var date

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .toggleCompletionAction:
                let completedAt = state.completedAt
                state.completedAt = completedAt == nil ? date.now : nil
                return .none
            case .tapAction:
                return .none
            }
        }
    }
}
