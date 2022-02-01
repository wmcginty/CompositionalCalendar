//
//  Month.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import Foundation

struct Timeline {
    
    // MARK: - Properties
    var years: [Year]
    let calendar: Calendar
    
    // MARK: - Initializers
    init(years: [Year], calendar: Calendar) {
        self.years = years
        self.calendar = calendar
    }
    
    init?(initialDate: Date, calendar: Calendar) {
        let year = calendar.component(.year, from: initialDate)
        let month = calendar.component(.month, from: initialDate)
        
        guard let monthRange = calendar.range(of: .month, in: .year, for: initialDate) else { return nil }
        
        let middleMonth = Int(Double(monthRange.upperBound - monthRange.lowerBound) * 0.5)
        if month >= middleMonth {
            self.init(years: [Year(year: year, calendar: calendar), Year(year: year + 1, calendar: calendar)].compactMap { $0 }, calendar: calendar)
        } else {
            self.init(years: [Year(year: year - 1, calendar: calendar), Year(year: year, calendar: calendar)].compactMap { $0 }, calendar: calendar)
        }
    }
    
    // MARK: - Interface
    var months: [Month] { return years.map(\.months).flatMap { $0 } }
    
    func indexPath(for date: Date) -> IndexPath? {
        return months.indexPath(for: date, using: calendar)
    }
    
    mutating func appendNextYear() {
        debugPrint("appending next year")
        if let maxYear = years.map(\.value).max(), let nextYear = Year(year: maxYear + 1, calendar: calendar) {
            years.append(nextYear)
        }
        
        years = Array(years.suffix(3))
    }
    
    mutating func appendPreviousYear() {
        debugPrint("appending previous year")
        if let minYear = years.map(\.value).min(), let previousYear = Year(year: minYear - 1, calendar: calendar) {
            years.insert(previousYear, at: years.startIndex)
        }
        
        years = Array(years.prefix(3))
    }
}

struct Year: Hashable {
    
    // MARK: - Properties
    let value: Int
    let months: [Month]
    let calendar: Calendar
    
    // MARK: - Initializers
    init(value: Int, months: [Month], calendar: Calendar) {
        self.value = value
        self.months = months
        self.calendar = calendar
    }
    
    init?(date: Date, calendar: Calendar) {
        let yearFromDate = calendar.component(.year, from: date)
        self.init(year: yearFromDate, calendar: calendar)
    }
    
    init?(year: Int, calendar: Calendar) {
        let baseDateComponents = DateComponents(calendar: calendar,year: year)
        guard let baseDate = baseDateComponents.date,
              let monthsInYear = calendar.range(of: .month, in: .year, for: baseDate) else { return nil }
        
        self.init(value: year, months: monthsInYear.compactMap { monthIndex in
            guard let baseDate = calendar.date(bySetting: .month, value: monthIndex, of: baseDate) else { return nil }
            return Month(baseDate: baseDate, calendar: calendar)
        }, calendar: calendar)
    }
    
    // MARK: - Interface
    func indexPath(for date: Date) -> IndexPath? {
        return months.indexPath(for: date, using: calendar)
    }
}

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
    var dayItems: Int { return days.count + (firstDateWeekday - 1) }
    
    func index(for date: Date) -> Int? {
        guard let dayIndex = days.firstIndex(where: { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }) else { return nil }
        return dayIndex + (firstDateWeekday - 1)
    }
    
    func day(for index: Int) -> Day? {
        // 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
        let zeroIndexedFirstDateWeekday = firstDateWeekday - 1
        guard index - zeroIndexedFirstDateWeekday >= 0 else { return nil }
        return days[index - zeroIndexedFirstDateWeekday]
    }
}

struct Day: Hashable {
    
    // MARK: - Properties
    let date: Date
    let index: Int
    let isInWeekend: Bool
}


// MARK: - [Month] Convenience
extension Array where Element == Month {
    
    func indexPath(for date: Date, using calendar: Calendar) -> IndexPath? {
        guard let month = first(where: { calendar.isDate($0.firstDate, equalTo: date, toGranularity: .month) }),
              let monthIndex = firstIndex(of: month), let dayIndex = month.index(for: date) else { return nil }
        
        return IndexPath(item: dayIndex, section: monthIndex)
    }
}
