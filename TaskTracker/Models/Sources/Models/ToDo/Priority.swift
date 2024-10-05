public enum Priority: String, Codable, CaseIterable, Identifiable, Sendable {
    public var id: Self { self }

    case high
    case normal
    case low
}
