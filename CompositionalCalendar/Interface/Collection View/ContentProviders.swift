//
//  ContentProviders.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import UIKit

// MARK: - CellContentProvider
class CellContentProvider {
    
    // MARK: - Subtypes
    enum DayViewModel {
        case day(Day)
        case adjacentMonth // The cell is there to occupy space in the calendar, but not display content for this month
        
        // MARK: - Initializer
        init(day: Day?) {
            switch day {
            case .some(let day): self = .day(day)
            case .none: self = .adjacentMonth
            }
        }
        
        // MARK: - Interface
        var formattedDate: String? {
            switch self {
            case .day(let day): return day.formattedDate
            default: return  nil
            }
        }
        
        var isInWeekend: Bool {
            switch self {
            case .day(let day): return day.isInWeekend
            default: return false
            }
        }
    }

    // MARK: - Properties
    let cell: UICollectionView.CellRegistration<UICollectionViewListCell, DayViewModel>

    // MARK: - Initializers
    init(cell: UICollectionView.CellRegistration<UICollectionViewListCell, DayViewModel> = .defaultCell) {
        self.cell = cell
    }

    // MARK: - Interface
    func cell(in collectionView: UICollectionView, at indexPath: IndexPath, for content: DayViewModel) -> UICollectionViewCell {
        return collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: content)
    }
}

// MARK: - SupplementaryContentProvider
class SupplementaryContentProvider {

    // MARK: - Properties
    let header: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>

    // MARK: - Initializer
    convenience init(sectionRetriever: @escaping (IndexPath) -> String) {
        self.init(header: .defaultHeader(for: sectionRetriever))
    }

    init(header: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>) {
        self.header = header
    }

    // MARK: - Interface
    func supplementaryView(in collectionView: UICollectionView, of kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        switch kind {
        case UICollectionView.elementKindSectionHeader: return collectionView.dequeueConfiguredReusableSupplementary(using: header, for: indexPath)
        default: return nil
        }
    }
}

// MARK: - Default Cell Registrations
extension UICollectionView.CellRegistration {

    static var defaultCell: UICollectionView.CellRegistration<UICollectionViewListCell, CellContentProvider.DayViewModel> {
        return .init { cell, _, viewModel in
            
            // The cell is not selected, configure the initial contents
            let contentConfiguration = UIListContentConfiguration.default(for: viewModel, isSelected: cell.isSelected, in: cell)
            cell.contentConfiguration = contentConfiguration
            
            cell.configurationUpdateHandler = { cell, state in
                //Re-configure the cell based on it's updated state
                guard let cell = cell as? UICollectionViewListCell else { return }
                
                let contentConfiguration = UIListContentConfiguration.default(for: viewModel, isSelected: state.isSelected, in: cell)
                cell.contentConfiguration = contentConfiguration
                
                let backgroundConfiguration = UIBackgroundConfiguration.default(forSelected: state.isSelected, in: cell)
                cell.backgroundConfiguration = backgroundConfiguration
            }
        }
    }
}

// MARK: - Default Supplementary View Registrations
extension UICollectionView.SupplementaryRegistration {

    static func defaultHeader(for section: @escaping (IndexPath) -> String) -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, _, indexPath in
            var contentConfiguration = supplementaryView.defaultContentConfiguration()
            contentConfiguration.text = section(indexPath)
            contentConfiguration.textProperties.color = .systemTeal

            supplementaryView.contentConfiguration = contentConfiguration
        }
    }
}

// MARK: - UIListContentConfiguration
fileprivate extension UIListContentConfiguration {
    
    static func `default`(for viewModel: CellContentProvider.DayViewModel, isSelected: Bool, in cell: UICollectionViewListCell) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = viewModel.formattedDate
        contentConfiguration.textProperties.alignment = .center
        contentConfiguration.textProperties.color = isSelected ? .systemBackground : .label
        contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .title3)
        contentConfiguration.directionalLayoutMargins = .zero
        
        if viewModel.isInWeekend && !isSelected {
            contentConfiguration.textProperties.color = .secondaryLabel
        }
        
        return contentConfiguration
    }
}

// MARK: - UIBackgroundConfiguration
fileprivate extension UIBackgroundConfiguration {
    
    static func `default`(forSelected selected: Bool, in cell: UICollectionViewCell) -> UIBackgroundConfiguration {
        var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
        
        if selected {
            backgroundConfiguration.backgroundColor = .systemTeal
            backgroundConfiguration.backgroundInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            backgroundConfiguration.cornerRadius = cell.bounds.width * 0.5
        }
        
        return backgroundConfiguration
    }
}
