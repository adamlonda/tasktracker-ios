import Foundation
import Tagged

public struct ToDo: Identifiable, Equatable, Codable {

    public let id: Tagged<Self, UUID>
    public var title: String
    public var note: String
    public var isCompleted: Bool

    public init(id: Tagged<Self, UUID>, title: String, note: String = "", isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
    }
}
