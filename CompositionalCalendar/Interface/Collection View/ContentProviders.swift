//
//  ContentProviders.swift
//  CustomCalendar
//
//  Created by Will McGinty on 1/30/22.
//

import UIKit

// MARK: - CellContentProvider
class CellContentProvider {

    // MARK: - Properties
    let cell: UICollectionView.CellRegistration<UICollectionViewListCell, Day>
    let emptyCell: UICollectionView.CellRegistration<UICollectionViewListCell, String>

    // MARK: - Initializers
    init(cell: UICollectionView.CellRegistration<UICollectionViewListCell, Day> = .defaultCell,
         emptyCell: UICollectionView.CellRegistration<UICollectionViewListCell, String> = .emptyCell) {
        self.cell = cell
        self.emptyCell = emptyCell
    }

    // MARK: - Interface
    func cell(in collectionView: UICollectionView, at indexPath: IndexPath, for content: Day?) -> UICollectionViewCell? {
        if let day = content {
            return collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: day)
        }
        
        return collectionView.dequeueConfiguredReusableCell(using: emptyCell, for: indexPath, item: "")
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

    static var defaultCell: UICollectionView.CellRegistration<UICollectionViewListCell, Day> {
        return .init { cell, _, day in
            let contentConfiguration = UIListContentConfiguration.default(for: day, isSelected: cell.isSelected, in: cell)
            cell.contentConfiguration = contentConfiguration
            
            cell.configurationUpdateHandler = { cell, state in
                guard let cell = cell as? UICollectionViewListCell else { return }
                
                let contentConfiguration = UIListContentConfiguration.default(for: day, isSelected: state.isSelected, in: cell)
                cell.contentConfiguration = contentConfiguration
                
                let backgroundConfiguration = UIBackgroundConfiguration.default(forSelected: state.isSelected, in: cell)
                cell.backgroundConfiguration = backgroundConfiguration
            }
        }
    }
    
    static var emptyCell: UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return .init { cell, _, configuration in }
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

// MARK: -
extension UIListContentConfiguration {
    
    static func `default`(for day: Day, isSelected: Bool, in cell: UICollectionViewListCell) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = day.date.formatted(.dateTime.day())
        contentConfiguration.textProperties.alignment = .center
        contentConfiguration.textProperties.color = isSelected ? .systemBackground : .label
        contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .title3)
        contentConfiguration.directionalLayoutMargins = .zero
        
        if day.isInWeekend && !isSelected {
            contentConfiguration.textProperties.color = .secondaryLabel
        }
        
        return contentConfiguration
    }
}

extension UIBackgroundConfiguration {
    
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
