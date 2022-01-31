//
//  Month.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import Foundation

struct Context {
    
    let weekdaySymbols: [String]

    init(calendar: Calendar) {
        self.weekdaySymbols = calendar.veryShortWeekdaySymbols
    }
}

struct Year {
    
    let months: [Month]
    
    init(months: [Month]) {
        self.months = months
    }
    
    init?(year: Int, calendar: Calendar) {
        let baseDateComponents = DateComponents(calendar: calendar,year: year)
        guard let baseDate = baseDateComponents.date,
              let monthsInYear = calendar.range(of: .month, in: .year, for: baseDate) else { return nil }
        
        self.init(months: monthsInYear.compactMap { monthIndex in
            guard let baseDate = calendar.date(bySetting: .month, value: monthIndex, of: baseDate) else { return nil }
            return Month(baseDate: baseDate, calendar: calendar)
        })
    }
}

struct Month {
    
    let days: [Day]
    let firstDate: Date
    let firstDateWeekday: Int
    
    init(days: [Day], firstDate: Date, firstDateWeekday: Int) {
        self.days = days
        self.firstDate = firstDate
        self.firstDateWeekday = firstDateWeekday
    }
    
    init?(baseDate: Date, calendar: Calendar) {
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: baseDate),
              let firstDayInMonth = calendar.date(from: calendar.dateComponents([.month, .year], from: baseDate)) else { return nil }
        let firstDayWeekday = calendar.component(.weekday, from: firstDayInMonth)
        
        let days: [Day] = daysInMonth.compactMap { day in
            guard let date = calendar.date(bySetting: .day, value: day, of: baseDate) else { return nil }
            return Day(date: date, index: day, isInWeekend: calendar.isDateInWeekend(date))
        }
        
        self.init(days: days, firstDate: firstDayInMonth, firstDateWeekday: firstDayWeekday)
    }
    
    var dayItems: Int {
        return days.count + (firstDateWeekday - 1)
    }
    
    func day(for index: Int) -> Day? {
        // 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
        let zeroIndexedFirstDateWeekday = firstDateWeekday - 1
        guard index - zeroIndexedFirstDateWeekday >= 0 else { return nil }
        
        return days[index - zeroIndexedFirstDateWeekday]
    }
}

struct Day: Hashable {
    
    let date: Date
    let index: Int
    let isInWeekend: Bool
}

extension Month {
    
    
//    // 1
//    func generateDaysInMonth(for baseDate: Date) -> [Day] {
//      // 2
//      guard let metadata = try? monthMetadata(for: baseDate) else {
//        fatalError("An error occurred when generating the metadata for \(baseDate)")
//      }
//
//      let numberOfDaysInMonth = metadata.numberOfDays
//      let offsetInInitialRow = metadata.firstDayWeekday
//      let firstDayOfMonth = metadata.firstDay
//
//      // 3
//      let days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
//        .map { day in
//          // 4
//          let isWithinDisplayedMonth = day >= offsetInInitialRow
//          // 5
//          let dayOffset =
//            isWithinDisplayedMonth ?
//            day - offsetInInitialRow :
//            -(offsetInInitialRow - day)
//          
//          // 6
//          return generateDay(
//            offsetBy: dayOffset,
//            for: firstDayOfMonth,
//            isWithinDisplayedMonth: isWithinDisplayedMonth)
//        }
//
//      return days
//    }
//
//    // 7
//    func generateDay(
//      offsetBy dayOffset: Int,
//      for baseDate: Date,
//      isWithinDisplayedMonth: Bool
//    ) -> Day {
//      let date = calendar.date(
//        byAdding: .day,
//        value: dayOffset,
//        to: baseDate)
//        ?? baseDate
//
//      return Day(
//        date: date,
//        number: dateFormatter.string(from: date),
//        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
//        isWithinDisplayedMonth: isWithinDisplayedMonth
//      )
//    }
   
}


