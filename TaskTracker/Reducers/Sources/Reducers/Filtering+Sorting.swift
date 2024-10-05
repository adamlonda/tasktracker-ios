import Foundation
import IdentifiedCollections
import Models

// MARK: - Filtering

extension Tab {

    func filteredTodos(
        from allTodos: IdentifiedArrayOf<ToDo>,
        for today: Date,
        calendar: Calendar
    ) -> IdentifiedArrayOf<ToDo> {
        switch self {
        case .all:
            return allTodos
        case .pending:
            return allTodos.filter { $0.completedAt == nil }
        case .completed:
            return allTodos.filter { $0.completedAt != nil }
        case .today:
            return allTodos.filter { $0.isListedFor(today: today, by: calendar) }
        }
    }
}

extension ToDo {

    func isListedFor(today: Date, by calendar: Calendar) -> Bool {
        guard completedAt == nil else {
            return false
        }
        guard let dueDate = dueDate else {
            return false
        }
        return dueDate < today || calendar.isDateInToday(dueDate)
    }
}

// MARK: - Sorting

extension Priority: @retroactive Comparable {

    private var sortOrder: Int {
        switch self {
        case .high:
            return 2
        case .normal:
            return 1
        case .low:
            return 0
        }
    }

    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

extension ToDo: @retroactive Comparable {

    private var completedAtSortOrder: Date {
        completedAt ?? Date.distantFuture
    }

    private var dueDateSortOrder: Date {
        dueDate ?? Date.distantFuture
    }

    public static func < (lhs: ToDo, rhs: ToDo) -> Bool {
        (lhs.completedAtSortOrder, rhs.dueDateSortOrder, lhs.priority)
        < (rhs.completedAtSortOrder, lhs.dueDateSortOrder, rhs.priority)
    }
}
