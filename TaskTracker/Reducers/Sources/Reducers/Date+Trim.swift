import Foundation

extension Date {
    func trim(with calendar: Calendar) -> Date? {
        let dateComponents = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            era: calendar.component(.era, from: self),
            year: calendar.component(.year, from: self),
            month: calendar.component(.month, from: self),
            day: calendar.component(.day, from: self),
            hour: 0,
            minute: 0,
            second: 0,
            nanosecond: 0
        )
        return calendar.date(from: dateComponents)
    }
}
