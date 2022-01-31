//
//  Month.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import Foundation

struct Year: Hashable {
    
    // MARK: - Properties
    let months: [Month]
    let calendar: Calendar
    
    // MARK: - Initializers
    init(months: [Month], calendar: Calendar) {
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
        
        self.init(months: monthsInYear.compactMap { monthIndex in
            guard let baseDate = calendar.date(bySetting: .month, value: monthIndex, of: baseDate) else { return nil }
            return Month(baseDate: baseDate, calendar: calendar)
        }, calendar: calendar)
    }
    
    // MARK: - Interface
    func indexPath(for date: Date) -> IndexPath? {
        guard let month = months.first(where: { calendar.isDate($0.firstDate, equalTo: date, toGranularity: .month) }),
              let monthIndex = months.firstIndex(of: month), let dayIndex = month.index(for: date) else { return nil }
        
        return IndexPath(item: dayIndex, section: monthIndex)
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
