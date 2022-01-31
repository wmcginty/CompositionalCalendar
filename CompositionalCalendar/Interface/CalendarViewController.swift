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
    @IBOutlet private var collectionView: UICollectionView!
    
    // MARK: - Properties
    let initialDate = Date()
    let calendar = Calendar.current
    let year = Year(year: 2022, calendar: .current)
    
    private lazy var dataSource: DataSource? = year.map(DataSource.init)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let context = Context(calendar: .current)
        weekdaysView.weekdaySymbols = context.weekdaySymbols
        
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        view.insertSubview(collectionView, belowSubview: weekdaysView)
        
        if let daysInWeek = calendar.range(of: .weekday, in: .weekOfYear, for: initialDate)?.count {
            collectionView.collectionViewLayout = makeLayout(forDaysInWeek: daysInWeek)
        }
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

