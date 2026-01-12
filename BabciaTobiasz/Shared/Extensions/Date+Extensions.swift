//
//  Date+Extensions.swift
//  BabciaTobiasz
//
//  Date utilities and formatting extensions.
//

import Foundation

extension Date {
    
    // MARK: - Relative Formatting
    
    /// Returns a human-readable relative time string
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns time in "h:mm a" format
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Returns date in "MMM d" format
    var shortDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    /// Returns day of week abbreviation
    var dayOfWeekFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    // MARK: - Date Comparisons
    
    /// Whether the date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Whether the date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Start of the day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// End of the day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
}
