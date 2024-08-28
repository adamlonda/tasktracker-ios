import ComposableArchitecture
import Foundation
import Models
import Tagged

@Reducer public struct TodoItemReducer {

    @ObservableState public struct State: Equatable, Identifiable {
        public var id: ToDo.ID { todo.id }
        public var todo: ToDo
        public var dueLabel: DueLabel?

        public init(todo: ToDo, dueLabel: DueLabel?) {
            self.todo = todo
            self.dueLabel = dueLabel
        }
    }

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
                let completedAt = state.todo.completedAt
                state.todo.completedAt = completedAt == nil ? date.now : nil
                return .none
            case .tapAction:
                return .none
            }
        }
    }
}

extension ToDo {
    public func dueLabel(calendar: Calendar, now: Date) -> DueLabel? {
        guard let dueDate = dueDate else {
            return nil
        }
        if calendar.isDateInToday(dueDate) {
            return .today
        } else if calendar.isDateInYesterday(dueDate) {
            return .yesterday
        } else if calendar.isDateInTomorrow(dueDate) {
            return .tomorrow
        } else if dueDate < now {
            return .overdue
        }

        let components = calendar.dateComponents([.day], from: now, to: dueDate)

        if let day = components.day, 0 < day && day < 6 {
            return .thisWeek
        }

        return .nextWeekAndBeyond
    }
}
