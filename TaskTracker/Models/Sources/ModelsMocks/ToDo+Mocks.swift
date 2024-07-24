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
        isCompleted: Bool = false
    ) -> Self {
        .init(id: id, title: title, note: note, isCompleted: isCompleted)
    }
}
