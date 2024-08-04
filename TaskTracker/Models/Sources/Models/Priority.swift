public enum Priority: String, Codable, CaseIterable, Identifiable {
    public var id: Self { self }

    case high
    case normal
    case low
}
