public enum Recurrence: Codable, CaseIterable, Hashable, Identifiable {
    public var id: Self { self }

    case never
    case daily
    case weekly
    case monthly
    case annually
}