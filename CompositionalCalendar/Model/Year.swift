//
//  Year.swift
//  CompositionalCalendar
//
//  Created by Will McGinty on 1/31/22.
//

import Foundation

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

// MARK: - [Year] Convenience
extension Array where Element == Year {
    
    static func year(for value: Int, andNextInDirection direction: Timeline.Direction, with calendar: Calendar) -> [Year] {
        switch direction {
        case .forwards:
            return [Year(year: value, calendar: calendar),
                    Year(year: value + 1, calendar: calendar)].compactMap { $0 }
            
        case .backwards:
            return [Year(year: value - 1, calendar: calendar),
                    Year(year: value, calendar: calendar)].compactMap { $0 }
        }
    }    
}
