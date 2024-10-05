import ComposableArchitecture
import Foundation
import Tagged

@ObservableState public struct ToDo: Identifiable, Equatable, Codable, Hashable, Sendable {

    public let id: Tagged<Self, UUID>
    public var title: String
    public var note: String
    public var completedAt: Date?
    public var priority: Priority
    public var dueDate: Date?
    public var recurrence: Recurrence

    public init(
        id: Tagged<Self, UUID>,
        title: String, note: String = "",
        completedAt: Date? = nil,
        priority: Priority = .normal,
        dueDate: Date? = nil,
        recurrence: Recurrence = .never
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.completedAt = completedAt
        self.priority = priority
        self.dueDate = dueDate
        self.recurrence = recurrence
    }
}
