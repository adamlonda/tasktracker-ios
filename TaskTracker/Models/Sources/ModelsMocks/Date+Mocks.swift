import Foundation

extension Date {

    public static func lastYear(from now: Date) -> Self {
        now.addingTimeInterval(-365 * 24 * 60 * 60)
    }

    public static func twoDays(before now: Date) -> Self {
        now.addingTimeInterval(-2 * 24 * 60 * 60)
    }

    public static func yesterday(from now: Date) -> Self {
        now.addingTimeInterval(-24 * 60 * 60)
    }

    public static func tomorrow(from now: Date) -> Self {
        now.addingTimeInterval(24 * 60 * 60)
    }

    public static func thisWeek(from now: Date) -> Self {
        now.addingTimeInterval(2 * 24 * 60 * 60)
    }

    public static func nextWeek(from now: Date) -> Self {
        now.addingTimeInterval(7 * 24 * 60 * 60)
    }

    public static func nextYear(from now: Date) -> Self {
        now.addingTimeInterval(365 * 24 * 60 * 60)
    }
}
