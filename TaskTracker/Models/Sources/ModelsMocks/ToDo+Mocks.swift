import Foundation
import Models
import Tagged

extension ToDo {

    public static var new: Self {
        .mock(title: "")
    }

    public static let highPriority: Self = .mock(title: "High Priority", priority: .high)
    public static let normalPriority: Self = .mock(title: "Normal Priority", priority: .normal)
    public static let lowPriority: Self = .mock(title: "Low Priority", priority: .low)

    public static func yearOverdue(from now: Date, title: String = "", recurrence: Recurrence = .never) -> Self {
        .mock(title: title, dueDate: .lastYear(from: now), recurrence: recurrence)
    }

    public static func twoDaysOverdue(from now: Date, title: String = "", recurrence: Recurrence = .never) -> Self {
        .mock(title: title, dueDate: .twoDays(before: now), recurrence: recurrence)
    }

    public static func dueYesterday(from now: Date, title: String = "", recurrence: Recurrence = .never) -> Self {
        .mock(title: title, dueDate: .yesterday(from: now), recurrence: recurrence)
    }

    public static func dueTomorrow(from now: Date, title: String = "", recurrence: Recurrence = .never) -> Self {
        .mock(title: title, dueDate: .tomorrow(from: now), recurrence: recurrence)
    }

    public static func dueThisWeek(from now: Date, title: String = "", recurrence: Recurrence = .never) -> Self {
        .mock(title: title, dueDate: .thisWeek(from: now), recurrence: recurrence)
    }

    public static func dueNextWeek(from now: Date, title: String = "", recurrence: Recurrence = .never) -> Self {
        .mock(title: title, dueDate: .nextWeek(from: now), recurrence: recurrence)
    }

    public static func dueNextYear(from now: Date, title: String = "", recurrence: Recurrence = .never) -> Self {
        .mock(title: title, dueDate: .nextYear(from: now), recurrence: recurrence)
    }

    public static func mock(
        id: ToDo.ID = ToDo.ID(),
        title: String = "",
        note: String = "",
        completedAt: Date? = nil,
        priority: Priority = .normal,
        dueDate: Date? = nil,
        recurrence: Recurrence = .never,
        trashedAt: Date? = nil
    ) -> Self {
        .init(
            id: id,
            title: title,
            note: note,
            completedAt: completedAt,
            priority: priority,
            dueDate: dueDate,
            recurrence: recurrence,
            trashedAt: trashedAt
        )
    }
}
