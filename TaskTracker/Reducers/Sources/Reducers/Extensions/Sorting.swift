import Foundation
import Models

extension Priority: Comparable {

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

extension ToDo: Comparable {

    private var completedAtSortOrder: Date {
        completedAt ?? Date.distantFuture
    }

    public static func < (lhs: ToDo, rhs: ToDo) -> Bool {
        (lhs.completedAtSortOrder, lhs.priority) < (rhs.completedAtSortOrder, rhs.priority)
    }
}
