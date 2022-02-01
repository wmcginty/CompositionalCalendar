//
//  Day.swift
//  CompositionalCalendar
//
//  Created by Will McGinty on 1/31/22.
//

import Foundation

struct Day: Hashable {
    
    // MARK: - Properties
    let date: Date
    let index: Int
    let isInWeekend: Bool
    
    // MARK: - Interface
    var formattedDate: String {
        return date.formatted(.dateTime.day())
    }
}
