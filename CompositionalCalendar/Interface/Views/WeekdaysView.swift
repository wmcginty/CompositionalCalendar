//
//  WeekdaysView.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import UIKit

class WeekdaysView: UIStackView {
    
    var weekdaySymbols: [String] = [] {
        didSet {
            arrangedSubviews.forEach { $0.removeFromSuperview() }
            weekdaySymbols.forEach { symbol in
                let label = UILabel(frame: .zero)
                label.textColor = .label
                label.text = symbol
                label.textAlignment = .center
                
                addArrangedSubview(label)
            }
        }
    }
}
