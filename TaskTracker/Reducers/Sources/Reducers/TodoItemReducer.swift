import ComposableArchitecture
import Foundation
import Models
import Tagged

@Reducer public struct TodoItemReducer {
    public typealias State = ToDo

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case completionAction
        case tapAction
    }

    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .completionAction:
                return reduceCompletion(state: &state)
            case .tapAction:
                return .none
            }
        }
    }

    private func reduceCompletion(state: inout State) -> Effect<Action> {
        switch state.recurrence {
        case .never:
            let completedAt = state.completedAt
            state.completedAt = completedAt == nil ? date.now : nil
            return .none
        case .daily:
            guard let dueDate = state.dueDate else { return .none }
            return reduceRecurrence(state: &state, with: calendar.date(byAdding: .day, value: 1, to: dueDate))
        case .weekly:
            guard let dueDate = state.dueDate else { return .none }
            return reduceRecurrence(state: &state, with: calendar.date(byAdding: .day, value: 7, to: dueDate))
        case .monthly:
            guard let dueDate = state.dueDate else { return .none }
            return reduceRecurrence(state: &state, with: calendar.date(byAdding: .month, value: 1, to: dueDate))
        case .annually:
            guard let dueDate = state.dueDate else { return .none }
            return reduceRecurrence(state: &state, with: calendar.date(byAdding: .year, value: 1, to: dueDate))
        }
    }

    private func reduceRecurrence(state: inout State, with newDueDate: Date?) -> Effect<Action> {
        state.dueDate = newDueDate?.trim(with: calendar)
        return .none
    }
}
