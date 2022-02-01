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
    var timeline: Timeline
    let calendar: Calendar
    let collectionView: UICollectionView
    private let contentProvider: CellContentProvider
    private var supplementaryProvider: SupplementaryContentProvider?
        
    // MARK: - Initializer
    init(timeline: Timeline, calendar: Calendar, collectionView: UICollectionView) {
        self.timeline = timeline
        self.calendar = calendar
        self.collectionView = collectionView
        
        self.contentProvider = CellContentProvider()
        super.init()
        
        self.supplementaryProvider = SupplementaryContentProvider { [unowned self] in
            return self.timeline.months[$0.section].firstDate.formatted(.dateTime.month(.wide).year())
        }
    }
    
    // MARK: - Interface
    func scrollToItem(for date: Date, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = true) {
        if let indexPath = timeline.indexPath(for: date) {
            collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
    
    func selectItem(for date: Date, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = true) {
        collectionView.selectItem(at: timeline.indexPath(for: date), animated: animated, scrollPosition: scrollPosition)
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
        return contentProvider.cell(in: collectionView, at: indexPath, for: month.day(for: indexPath.item))!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return supplementaryProvider!.supplementaryView(in: collectionView, of: kind, at: indexPath)!
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
    
//    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//        let attrs = collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath)
//    }
}

// MARK: - CalendarCollectionViewDelegate
extension CalendarCollectionController: CalendarCollectionViewDelegate {
    
    func calendarCollectionViewWillLayoutSubviews(_ collectionView: CalendarCollectionView) {
        if collectionView.contentOffset.y < 0 {
            
            //add()
            print(collectionView.contentOffset)
//            collectionView.reloadData()
//            collectionView.collectionViewLayout.invalidateLayout()
//            collectionView.collectionViewLayout.prepare()
            
            add(forward: false)
//            collectionView.setContentOffset(.zero, animated: false)
            //collectionView.contentOffset = .init(x: 0, y: 10)
            print(collectionView.contentOffset)
        }
        
        
        if collectionView.contentSize.height > 0, collectionView.contentOffset.y > collectionView.contentSize.height - collectionView.bounds.height {
            //timeline.appendNextYear()
            
            add(forward: true)
//            collectionView.reloadData()
//            collectionView.collectionViewLayout.invalidateLayout()
//            collectionView.collectionViewLayout.prepare()
        }
    }
    
    func add(forward: Bool) {
        //collectionView.reloadData()
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        if visibleIndexPaths.isEmpty {
             return
        }
        
        let fromIndexPath = visibleIndexPaths.first!
        let fromSection = fromIndexPath.section
        let fromSectionOfDate = timeline.months[fromSection].firstDate
        let attrs = collectionView.collectionViewLayout.layoutAttributesForItem(at: .init(item: 0, section: fromSection))
        let fromSectionOrigin = attrs!.frame.origin
        
        if forward {
            timeline.appendNextYear()
        } else {
            timeline.appendPreviousYear()
        }
        
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.collectionViewLayout.prepare()
        //restore selection
        
        let toSection = timeline.months.firstIndex(where: { $0.firstDate == fromSectionOfDate })!
        let toATtrs = collectionView.collectionViewLayout.layoutAttributesForItem(at: .init(item: 0, section: toSection))
        let toOrigin = toATtrs!.frame.origin
        
        collectionView.contentOffset = .init(x: collectionView.contentOffset.x,
                                              y: max(0, collectionView.contentOffset.y + (toOrigin.y - fromSectionOrigin.y)))
        
        
        //NSInteger toSection = [self sectionForDate:fromSectionOfDate];
        //    UICollectionViewLayoutAttributes *toAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:toSection]];
        //    CGPoint toSectionOrigin = [self convertPoint:toAttrs.frame.origin fromView:cv];
        //
        //    [cv setContentOffset:(CGPoint) {
        //        cv.contentOffset.x,
        //        cv.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
        //    }];
        
    }
}

//
//- (void)shiftDatesByComponents:(NSDateComponents *)components
//{
//    RSDFDatePickerCollectionView *cv = self.collectionView;
//    RSDFDatePickerCollectionViewLayout *cvLayout = (RSDFDatePickerCollectionViewLayout *)self.collectionView.collectionViewLayout;
//    
//    NSArray *visibleCells = [cv visibleCells];
//    if (![visibleCells count])
//        return;
//    
//    NSIndexPath *fromIndexPath = [cv indexPathForCell:((UICollectionViewCell *)visibleCells[0])];
//    NSInteger fromSection = fromIndexPath.section;
//    NSDate *fromSectionOfDate = [self dateForFirstDayInSection:fromSection];
//    UICollectionViewLayoutAttributes *fromAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:fromSection]];
//    CGPoint fromSectionOrigin = [self convertPoint:fromAttrs.frame.origin fromView:cv];
//    
//    if (!self.startDate) {
//        _fromDate = [self dateWithFirstDayOfMonth:[self.calendar dateByAddingComponents:components toDate:self.fromDate options:0]];
//    }
//    
//    if (!self.endDate) {
//        _toDate = [self dateWithFirstDayOfMonth:[self.calendar dateByAddingComponents:components toDate:self.toDate options:0]];
//    }
//    
//#if 0
//    
//    //    This solution trips up the collection view a bit
//    //    because our reload is reactionary, and happens before a relayout
//    //    since we must do it to avoid flickering and to heckle the CA transaction (?)
//    //    that could be a small red flag too.
//    
//    [cv performBatchUpdates:^{
//        
//        if (components.month < 0) {
//            
//            [cv deleteSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
//                cv.numberOfSections - abs(components.month),
//                abs(components.month)
//            }]];
//            
//            [cv insertSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
//                0,
//                abs(components.month)
//            }]];
//            
//        } else {
//            
//            [cv insertSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
//                cv.numberOfSections,
//                abs(components.month)
//            }]];
//            
//            [cv deleteSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
//                0,
//                abs(components.month)
//            }]];
//            
//        }
//        
//    } completion:^(BOOL finished) {
//        
//        NSLog(@"%s %x", __PRETTY_FUNCTION__, finished);
//        
//    }];
//    
//    for (UIView *view in cv.subviews)
//        [view.layer removeAllAnimations];
//    
//#else
//    
//    [cv reloadData];
//    [cvLayout invalidateLayout];
//    [cvLayout prepareLayout];
//    
//    [self restoreSelection];
//    
//#endif
//    
//    NSInteger toSection = [self sectionForDate:fromSectionOfDate];
//    UICollectionViewLayoutAttributes *toAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:toSection]];
//    CGPoint toSectionOrigin = [self convertPoint:toAttrs.frame.origin fromView:cv];
//    
//    [cv setContentOffset:(CGPoint) {
//        cv.contentOffset.x,
//        cv.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
//    }];
//}

//- (void)restoreSelection
//{
//    if (self.selectedDate &&
//        [self.selectedDate compare:self.fromDate] != NSOrderedAscending &&
//        [self.selectedDate compare:self.toDate] == NSOrderedAscending) {
//        NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:self.selectedDate];
//        [self.collectionView selectItemAtIndexPath:indexPathForSelectedDate animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//        UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPathForSelectedDate];
//        if (selectedCell) {
//            [selectedCell setNeedsDisplay];
//        }
//    }
//}
//
//- (void)selectDate:(NSDate *)date
//{
//    if (![self.selectedDate isEqual:date]) {
//        if (self.selectedDate &&
//            [self.selectedDate compare:self.fromDate] != NSOrderedAscending &&
//            [self.selectedDate compare:self.toDate] == NSOrderedAscending) {
//            NSIndexPath *previousSelectedCellIndexPath = [self indexPathForDate:self.selectedDate];
//            [self.collectionView deselectItemAtIndexPath:previousSelectedCellIndexPath animated:NO];
//            UICollectionViewCell *previousSelectedCell = [self.collectionView cellForItemAtIndexPath:previousSelectedCellIndexPath];
//            if (previousSelectedCell) {
//                [previousSelectedCell setNeedsDisplay];
//            }
//        }
//
//        _selectedDate = date;
//
//        if (self.selectedDate &&
//            [self.selectedDate compare:self.fromDate] != NSOrderedAscending &&
//            [self.selectedDate compare:self.toDate] == NSOrderedAscending) {
//            NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:self.selectedDate];
//            [self.collectionView selectItemAtIndexPath:indexPathForSelectedDate animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//            UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPathForSelectedDate];
//            if (selectedCell) {
//                [selectedCell setNeedsDisplay];
//            }
//        }
//    }
//}
