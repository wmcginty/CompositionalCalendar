//
//  DataSource.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import Foundation
import UIKit

class DataSource: NSObject {
    
    let year: Year
    private let contentProvider: CellContentProvider
    private let supplementaryProvider: SupplementaryContentProvider
        
    init(year: Year) {
        self.year = year
        self.contentProvider = CellContentProvider()
        self.supplementaryProvider = SupplementaryContentProvider {
            return year.months[$0.section].firstDate.formatted(.dateTime.month(.wide))
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DataSource: UICollectionViewDataSource {
    
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
extension DataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let month = year.months[indexPath.section]
        return month.day(for: indexPath.item) != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let month = year.months[indexPath.section]
        return month.day(for: indexPath.item) != nil
    }
}
