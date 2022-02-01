//
//  Timeline.swift
//  CompositionalCalendar
//
//  Created by Will McGinty on 1/31/22.
//

import Foundation

struct Timeline {
    
    // MARK: - Subtypes
    enum Direction {
        case forwards, backwards
    }
    
    // MARK: - Properties
    var years: [Year]
    let calendar: Calendar
    
    // MARK: - Initializers
    init(years: [Year], calendar: Calendar) {
        self.years = years
        self.calendar = calendar
    }
    
    init?(initialDate: Date, calendar: Calendar) {
        guard let monthRange = calendar.range(of: .month, in: .year, for: initialDate) else { return nil }
        
        let year = calendar.component(.year, from: initialDate)
        let month = calendar.component(.month, from: initialDate)
        let middleMonth = Int(Double(monthRange.upperBound - monthRange.lowerBound) * 0.5)
        self.init(years: .year(for: year, andNextInDirection: month > middleMonth ? .forwards : .backwards, with: calendar), calendar: calendar)
    }
    
    // MARK: - Interface
    var months: [Month] { return years.map(\.months).flatMap { $0 } }
    
    var earliestYear: Int? { return years.map(\.value).min() }
    var latestYear: Int? { return years.map(\.value).max() }
    
    func indexPath(for date: Date) -> IndexPath? {
        return months.indexPath(for: date, using: calendar)
    }
    
    mutating func appendYear(in direction: Direction) {
        switch direction {
        case .forwards:
            if let nextYear = latestYear.flatMap({ Year(year: $0 + 1, calendar: calendar) }) {
                years.append(nextYear)
                years = Array(years.suffix(3))
            }
            
        case .backwards:
            if let previousYear = earliestYear.flatMap({ Year(year: $0 - 1, calendar: calendar) }) {
                years.insert(previousYear, at: years.startIndex)
                years = Array(years.prefix(3))
            }
        }
    }
}
