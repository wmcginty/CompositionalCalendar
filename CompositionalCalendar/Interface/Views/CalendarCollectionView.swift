//
//  CalendarCollectionView.swift
//  CompositionalCalendar
//
//  Created by Will McGinty on 1/31/22.
//

import Foundation
import UIKit

protocol CalendarCollectionViewDelegate: AnyObject {
    func calendarCollectionViewWillLayoutSubviews(_ collectionView: CalendarCollectionView)
}

class CalendarCollectionView: UICollectionView {
    
    weak var calendarScrollDelegate: CalendarCollectionViewDelegate?
    
    override func layoutSubviews() {
        calendarScrollDelegate?.calendarCollectionViewWillLayoutSubviews(self)
        super.layoutSubviews()
    }
}
