//
//  CalendarCollectionController.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import Foundation
import UIKit

class CalendarCollectionController: NSObject {
    
    // MARK: - Properties
    let year: Year
    let calendar: Calendar
    let collectionView: UICollectionView
    private let contentProvider: CellContentProvider
    private let supplementaryProvider: SupplementaryContentProvider
        
    // MARK: - Initializer
    init(year: Year, calendar: Calendar, collectionView: UICollectionView) {
        self.year = year
        self.calendar = calendar
        self.collectionView = collectionView
        
        self.contentProvider = CellContentProvider()
        self.supplementaryProvider = SupplementaryContentProvider {
            return year.months[$0.section].firstDate.formatted(.dateTime.month(.wide).year())
        }
    }
    
    // MARK: - Interface
    func scrollToItem(for date: Date, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = true) {
        if let indexPath = year.indexPath(for: date) {
            collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
    
    func selectItem(for date: Date, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = true) {
        collectionView.selectItem(at: year.indexPath(for: date), animated: animated, scrollPosition: scrollPosition)
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarCollectionController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return year.months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let month = year.months[section]
        return month.dayItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let month = year.months[indexPath.section]
        return contentProvider.cell(in: collectionView, at: indexPath, for: month.day(for: indexPath.item))!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return supplementaryProvider.supplementaryView(in: collectionView, of: kind, at: indexPath)!
    }
}

// MARK: - UICollectionViewDelegate
extension CalendarCollectionController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let month = year.months[indexPath.section]
        return month.day(for: indexPath.item) != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let month = year.months[indexPath.section]
        return month.day(for: indexPath.item) != nil
    }
}
