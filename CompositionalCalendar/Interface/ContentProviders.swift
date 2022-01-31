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
        return .init { cell, _, configuration in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = String(configuration.index)
            contentConfiguration.textProperties.alignment = .center
            contentConfiguration.directionalLayoutMargins = .zero
            
            if configuration.isInWeekend {
                contentConfiguration.textProperties.color = .lightGray
            }
            cell.contentConfiguration = contentConfiguration
            
            cell.configurationUpdateHandler = { cell, state in
                var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
                
                if cell.isSelected {
                    backgroundConfiguration.backgroundColor = .red
                    backgroundConfiguration.cornerRadius = cell.bounds.width * 0.5
                }
                
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

            supplementaryView.contentConfiguration = contentConfiguration
        }
    }
}
