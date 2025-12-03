import Foundation

// MARK: - Date Helper Functions

struct DateHelpers {

    /// Returns the ordinal suffix for a day number (e.g., "st", "nd", "rd", "th")
    static func getOrdinalSuffix(for day: Int) -> String {
        let exceptions = [11, 12, 13]
        if exceptions.contains(day) {
            return "th"
        }

        switch day % 10 {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }

    /// Formats a date with ordinal suffix (e.g., "December 1st")
    static func formatDateWithOrdinal(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        let baseString = formatter.string(from: date)

        let day = Calendar.current.component(.day, from: date)
        let suffix = getOrdinalSuffix(for: day)

        return baseString + suffix
    }

    /// Checks if a date is today
    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Checks if two dates are on the same day
    static func areSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }

    /// Returns the start of day for a given date
    static func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}

// MARK: - Date Extensions

extension Date {
    /// Returns the ordinal suffix for the day (e.g., "st", "nd", "rd", "th")
    var dayOrdinalSuffix: String {
        let day = Calendar.current.component(.day, from: self)
        return DateHelpers.getOrdinalSuffix(for: day)
    }

    /// Formats the date with ordinal suffix (e.g., "December 1st")
    var formattedWithOrdinal: String {
        DateHelpers.formatDateWithOrdinal(self)
    }

    /// Returns true if the date is today
    var isToday: Bool {
        DateHelpers.isToday(self)
    }

    /// Checks if this date is on the same day as another date
    func isSameDay(as otherDate: Date) -> Bool {
        DateHelpers.areSameDay(self, otherDate)
    }

    /// Returns the start of the day for this date
    var startOfDay: Date {
        DateHelpers.startOfDay(for: self)
    }
}
