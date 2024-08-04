import ComposableArchitecture
import Foundation
import Tagged

@ObservableState public struct ToDo: Identifiable, Equatable, Codable {

    public let id: Tagged<Self, UUID>
    public var title: String
    public var note: String
    public var completedAt: Date?
    public var priority: Priority

    public init(
        id: Tagged<Self, UUID>,
        title: String, note: String = "",
        completedAt: Date? = nil,
        priority: Priority = .normal
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.completedAt = completedAt
        self.priority = priority
    }
}
