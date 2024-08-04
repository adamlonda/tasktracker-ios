import Foundation
import Models
import Tagged

extension ToDo {

    public static var new: Self {
        .mock(title: "")
    }

    public static func mock(
        id: ToDo.ID = ToDo.ID(),
        title: String,
        note: String = "",
        completedAt: Date? = nil,
        priority: Priority = .normal
    ) -> Self {
        .init(id: id, title: title, note: note, completedAt: completedAt, priority: priority)
    }
}
