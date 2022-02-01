//
//  CalendarViewController.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import UIKit

class CalendarViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private var weekdaysView: WeekdaysView!
    @IBOutlet private var collectionView: CalendarCollectionView!
    
    // MARK: - Properties
    let initialDate = Date()
    let calendar = Calendar.current
    
    private lazy var timeline = Timeline(initialDate: initialDate, calendar: calendar)
    private lazy var collectionController: CalendarCollectionController? = timeline.map {
        .init(timeline: $0, calendar: calendar, collectionView: collectionView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"

        // Configure the weekday view
        weekdaysView.weekdaySymbols = calendar.veryShortWeekdaySymbols
        
        // Configure the calendar collection view
        view.insertSubview(collectionView, belowSubview: weekdaysView)
        collectionView.dataSource = collectionController
        collectionView.delegate = collectionController
        collectionView.calendarScrollDelegate = collectionController
        
        if let daysInWeek = calendar.range(of: .weekday, in: .weekOfYear, for: initialDate)?.count {
            collectionView.collectionViewLayout = makeLayout(forDaysInWeek: daysInWeek)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionController?.scrollToItem(for: initialDate, at: .centeredVertically, animated: false)
        //collectionController?.selectItem(for: initialDate, at: .centeredVertically)
    }
}

// MARK: - Layout
private extension CalendarViewController {
    
    func makeLayout(forDaysInWeek daysInWeek: Int) -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(daysInWeek)),
                                              heightDimension: .fractionalWidth(1.0 / CGFloat(daysInWeek)))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                             heightDimension: .estimated(100)),
                                                                             subitem: item, count: daysInWeek)
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [
                .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                      elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            ]
            section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
            
            return section
        }
    }
}

