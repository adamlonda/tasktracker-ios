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

    public static func mock(
        id: ToDo.ID = ToDo.ID(),
        title: String,
        note: String = "",
        completedAt: Date? = nil,
        priority: Priority = .normal,
        dueDate: Date? = nil
    ) -> Self {
        .init(id: id, title: title, note: note, completedAt: completedAt, priority: priority, dueDate: dueDate)
    }
}
