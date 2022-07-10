//
//  ConfigurationsViewController.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/24/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

typealias Provider<T> = () -> T

struct SectionConfiguration {

  let headerContentProvider: (() -> UIContentConfiguration?)?
  let footerContentProvider: (() -> UIContentConfiguration?)?
  let items: [ItemConfiguration]

  init(headerContentProvider: (() -> UIContentConfiguration?)? = nil, footerContentProvider: (() -> UIContentConfiguration?)? = nil, items: [ItemConfiguration]) {
    self.headerContentProvider = headerContentProvider
    self.footerContentProvider = footerContentProvider
    self.items = items
  }

  static func plain(headerText: String? = nil, footerText: String? = nil, items: [ItemConfiguration] = []) -> Self {
    var headerContentProvider: (() -> UIContentConfiguration?)?
    var footerContentProvider: (() -> UIContentConfiguration?)?
    if let headerText = headerText {
      headerContentProvider = {
        var content = UIListContentConfiguration.plainHeader()
        content.text = headerText
        return content
      }
    }
    if let footerText = footerText {
      footerContentProvider = {
        var content = UIListContentConfiguration.plainFooter()
        content.text = footerText
        return content
      }
    }
    return .init(
      headerContentProvider: headerContentProvider,
      footerContentProvider: footerContentProvider,
      items: items
    )
  }
}

struct ItemConfiguration {

  typealias SelectionHandler = (UICollectionView, IndexPath) -> Void

  let contentProvider: () -> UIContentConfiguration
  let accessories: [UICellAccessory]
  let selectionHandler: SelectionHandler?

  init(contentProvider: @escaping () -> UIContentConfiguration, accessories: [UICellAccessory] = [], selectionHandler: SelectionHandler? = nil) {
    self.contentProvider = contentProvider
    self.accessories = accessories
    self.selectionHandler = selectionHandler
  }

  static func action(
    title: String,
    titleColor: UIColor = .accent,
    secondaryTextProvider: Provider<String?>? = nil,
    updateHandler: ((inout UIListContentConfiguration) -> Void)? = nil,
    selectionHandler: SelectionHandler? = nil
  ) -> Self {
    return value(
      image: nil,
      text: title,
      secondaryTextProvider: secondaryTextProvider,
      updateHandler: { content in
        content.textProperties.color = titleColor
        updateHandler?(&content)
      },
      accessories: [],
      selectionHandler: selectionHandler
    )
  }

  static func `default`(image: UIImage? = nil, text: String, secondaryTextProvider: Provider<String?>? = nil, updateHandler: ((inout UIListContentConfiguration) -> Void)? = nil, accessories: [UICellAccessory] = [], selectionHandler: SelectionHandler? = nil) -> Self {
    return .init(
      contentProvider: {
        var content = UIListContentConfiguration.cell()
        updateHandler?(&content)
        content.image = image
        content.text = text
        content.secondaryText = secondaryTextProvider?()
        return content
      },
      accessories: accessories,
      selectionHandler: selectionHandler
    )
  }

  static func value(image: UIImage? = nil, text: String, secondaryText: String?, updateHandler: ((inout UIListContentConfiguration) -> Void)? = nil, accessories: [UICellAccessory] = [], selectionHandler: SelectionHandler? = nil) -> Self {
    return .init(
      contentProvider: {
        var content = UIListContentConfiguration.valueCell()
        updateHandler?(&content)
        content.image = image
        content.text = text
        content.secondaryText = secondaryText
        return content
      },
      accessories: accessories,
      selectionHandler: selectionHandler
    )
  }

  static func value(image: UIImage? = nil, text: String, secondaryTextProvider: Provider<String?>?, updateHandler: ((inout UIListContentConfiguration) -> Void)? = nil, accessories: [UICellAccessory] = [], selectionHandler: SelectionHandler? = nil) -> Self {
    return .init(
      contentProvider: {
        var content = UIListContentConfiguration.valueCell()
        updateHandler?(&content)
        content.image = image
        content.text = text
        content.secondaryText = secondaryTextProvider?()
        return content
      },
      accessories: accessories,
      selectionHandler: selectionHandler
    )
  }
}

class ConfigurationsViewController: CollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  var sections: [SectionConfiguration]!

  override func makeCollectionViewLayout() -> UICollectionViewLayout {
    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.contentInsetsReference = .layoutMargins
    return UICollectionViewCompositionalLayout(sectionProvider: { [unowned self] sectionIndex, layoutEnviroment in
      var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      configuration.headerMode = self.sections[sectionIndex].headerContentProvider?() == nil ? .none : .supplementary
      configuration.footerMode = self.sections[sectionIndex].footerContentProvider?() == nil ? .none : .supplementary
      configuration.backgroundColor = .clear
      let layoutSection = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnviroment)
      return layoutSection
    }, configuration: configuration)
  }

  override func collectionViewDidLoad() {
    super.collectionViewDidLoad()

    collectionView.register(UICollectionViewListCell.self)
    collectionView.register(UICollectionViewCell.self, identifier: "HeaderView", ofKind: UICollectionView.elementKindSectionHeader)
    collectionView.register(UICollectionViewCell.self, identifier: "FooterView", ofKind: UICollectionView.elementKindSectionFooter)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemGroupedBackground
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return sections.count
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sections[section].items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeue(UICollectionViewListCell.self, for: indexPath)
    let item = sections[indexPath.section].items[indexPath.item]
    cell.contentConfiguration = item.contentProvider()
    cell.accessories = item.accessories
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let section = sections[indexPath.section]
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      let view = collectionView.dequeue(UICollectionViewCell.self, identifier: "HeaderView", ofKind: kind, for: indexPath)
      view.contentConfiguration = section.headerContentProvider?()
      return view

    case UICollectionView.elementKindSectionFooter:
      let view = collectionView.dequeue(UICollectionViewCell.self, identifier: "FooterView", ofKind: kind, for: indexPath)
      view.contentConfiguration = section.footerContentProvider?()
      return view

    default:
      fatalError()
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)

    let item = sections[indexPath.section].items[indexPath.item]
    item.selectionHandler?(collectionView, indexPath)
  }
}
