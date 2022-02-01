//
//  CalendarCollectionController.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import UIKit

class CalendarCollectionController: NSObject {
    
    // MARK: - Properties
    var timeline: Timeline
    let calendar: Calendar
    let collectionView: UICollectionView
    
    private let contentProvider: CellContentProvider
    private var supplementaryProvider: SupplementaryContentProvider?
    private var selectedIndexPath: IndexPath?
        
    // MARK: - Initializer
    init(timeline: Timeline, calendar: Calendar, collectionView: UICollectionView) {
        self.timeline = timeline
        self.calendar = calendar
        self.collectionView = collectionView
        self.contentProvider = CellContentProvider()
        super.init()
        
        self.supplementaryProvider = SupplementaryContentProvider { [unowned self] in
            self.timeline.months[$0.section].formattedFirstDate
        }
    }
    
    // MARK: - Interface
    func scrollToItem(for date: Date, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = true) {
        if let indexPath = timeline.indexPath(for: date) {
            collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
    
    func selectItem(for date: Date, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = true) {
        if let indexPath = timeline.indexPath(for: date) {
            selectedIndexPath = indexPath
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarCollectionController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return timeline.months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let month = timeline.months[section]
        return month.dayItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let month = timeline.months[indexPath.section]
        return contentProvider.cell(in: collectionView, at: indexPath,
                                    for: CellContentProvider.DayViewModel(day: month.day(for: indexPath.item)))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let supplementaryView = supplementaryProvider?.supplementaryView(in: collectionView, of: kind, at: indexPath) else {
            fatalError("Could not find supplementary view of kind \(kind) for indexPath: \(indexPath)")
        }
        
        return supplementaryView
    }
}

// MARK: - UICollectionViewDelegate
extension CalendarCollectionController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let month = timeline.months[indexPath.section]
        return month.day(for: indexPath.item) != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let month = timeline.months[indexPath.section]
        return month.day(for: indexPath.item) != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
}

// MARK: - CalendarCollectionViewDelegate
extension CalendarCollectionController: CalendarCollectionViewDelegate {
    
    func calendarCollectionViewWillLayoutSubviews(_ collectionView: CalendarCollectionView) {
        if collectionView.contentOffset.y < 0 {
            // If we've scrolled past the top - add more content before the current set
            appendToTimeline(in: .backwards)
            
        } else if collectionView.contentSize.height > 0, collectionView.contentOffset.y > collectionView.contentSize.height - collectionView.bounds.height {
            // If we've scrolled past the bottom - add more content after the current set
            appendToTimeline(in: .forwards)
        }
    }
    
    func appendToTimeline(in direction: Timeline.Direction) {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        
        guard let beforeIndexPath = visibleIndexPaths.first else { return }
        let beforeSection = beforeIndexPath.section
        let beforeSectionFirstDate = timeline.months[beforeSection].firstDate
        
        guard let beforeSectionLayoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: .init(item: 0, section: beforeSection)) else { return }
        let beforeSectionOrigin = beforeSectionLayoutAttributes.frame.origin
        
        // Update the data model, and reload the collection view
        timeline.appendYear(in: direction)
       
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
        
        if let afterSection = timeline.months.firstIndex(where: { $0.firstDate == beforeSectionFirstDate }),
           let afterSectionLayoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: .init(item: 0, section: afterSection)) {
            let afterSectionOrigin = afterSectionLayoutAttributes.frame.origin
            collectionView.contentOffset = .init(x: collectionView.contentOffset.x,
                                                 y: collectionView.contentOffset.y + (afterSectionOrigin.y - beforeSectionOrigin.y))
        }
    }
}
