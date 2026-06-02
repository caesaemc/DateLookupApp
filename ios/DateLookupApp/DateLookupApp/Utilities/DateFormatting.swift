import Foundation

extension DateFormatter {
    static let monthKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    static let dayKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let monthTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()

    static let dayTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter
    }()
}

enum CalendarGridBuilder {
    static func monthGrid(for month: Date, calendar: Calendar = .sundayFirstGregorian) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1)) else {
            return []
        }

        var days: [Date] = []
        var current = firstWeek.start
        while current < lastWeek.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? lastWeek.end
        }
        return days
    }
}

extension Calendar {
    static var sundayFirstGregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.firstWeekday = 1
        return calendar
    }
}
