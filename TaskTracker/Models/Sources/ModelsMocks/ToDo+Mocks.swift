import Models

extension ToDo {

    public static var new: Self {
        .mock(title: "")
    }

    public static func mock(title: String, isCompleted: Bool = false) -> Self {
        .init(id: ToDo.ID(), title: title, isCompleted: isCompleted)
    }
}
