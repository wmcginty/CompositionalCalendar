//
//  Month.swift
//  CompositionalCalendar
//
//  Created by Will McGinty on 1/31/22.
//

import Foundation

struct Month: Hashable {
    
    // MARK: - Properties
    let days: [Day]
    let firstDate: Date
    let firstDateWeekday: Int
    let calendar: Calendar
    
    // MARK: - Initializers
    init(days: [Day], firstDate: Date, firstDateWeekday: Int, calendar: Calendar) {
        self.days = days
        self.firstDate = firstDate
        self.firstDateWeekday = firstDateWeekday
        self.calendar = calendar
    }
    
    init?(baseDate: Date, calendar: Calendar) {
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: baseDate),
              let firstDayInMonth = calendar.date(from: calendar.dateComponents([.month, .year], from: baseDate)) else { return nil }
        let firstDayWeekday = calendar.component(.weekday, from: firstDayInMonth)
        
        let days: [Day] = daysInMonth.compactMap { day in
            guard let date = calendar.date(bySetting: .day, value: day, of: baseDate) else { return nil }
            return Day(date: date, index: day, isInWeekend: calendar.isDateInWeekend(date))
        }
        
        self.init(days: days, firstDate: firstDayInMonth, firstDateWeekday: firstDayWeekday, calendar: calendar)
    }
    
    // MARK: - Interface
    var formattedFirstDate: String {
        return firstDate.formatted(.dateTime.month(.wide).year())
    }
    
    var dayItems: Int { return days.count + (firstDateWeekday - 1) }
    
    func index(for date: Date) -> Int? {
        guard let dayIndex = days.firstIndex(where: { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }) else { return nil }
        return dayIndex + zeroIndexedFirstDateWeekday
    }
    
    func day(for index: Int) -> Day? {
        // 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
        guard index - zeroIndexedFirstDateWeekday >= 0 else { return nil }
        return days[index - zeroIndexedFirstDateWeekday]
    }
}

// MARK: - Helper
private extension Month {
    
    var zeroIndexedFirstDateWeekday: Int {
        return firstDateWeekday - 1
    }
}

// MARK: - [Month] Convenience
extension Array where Element == Month {
    
    func indexPath(for date: Date, using calendar: Calendar) -> IndexPath? {
        guard let month = first(where: { calendar.isDate($0.firstDate, equalTo: date, toGranularity: .month) }),
              let monthIndex = firstIndex(of: month), let dayIndex = month.index(for: date) else { return nil }
        
        return IndexPath(item: dayIndex, section: monthIndex)
    }
}
