import Models

extension ToDo {

    public static var new: Self {
        .mock(title: "")
    }

    public static func mock(title: String) -> Self {
        .init(id: ToDo.ID(), title: title)
    }
}
