//
//  FormViewController.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/21/22.
//

import UIKit
import UIKitSwift
import SwiftKit

extension NSCollectionLayoutGroup {

  static func horizontal(layoutSize: NSCollectionLayoutSize, itemFractionalWidths: [CGFloat], contentSpacing: CGFloat) -> Self {
    let totalFractionalWidth = itemFractionalWidths.sum()
    let itemFractionalWidths = itemFractionalWidths.map { $0 / totalFractionalWidth }
    let items = itemFractionalWidths.map { NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth($0), heightDimension: layoutSize.heightDimension)) }
    let halfContentSpacing = contentSpacing / 2
    for (index, item) in items.enumerated() {
      item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: index == 0 ? 0 : halfContentSpacing, bottom: 0, trailing: index == items.count - 1 ? 0 : halfContentSpacing)
    }
    return horizontal(layoutSize: layoutSize, subitems: items)
  }
}

class FormViewController: CollectionViewController, UICollectionViewDataSource, UIAdaptivePresentationControllerDelegate {

  var hasChanges: Bool {
    return false
  }

  override init(nibName: String? = nil, bundle: Bundle? = nil) {
    super.init(nibName: nibName, bundle: bundle)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func willMove(toParent parent: UIViewController?) {
    if let navigationController = parent as? UINavigationController {
      navigationController.presentationController?.delegate = self
      if navigationController.viewControllers.first == self {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "action.cancel".localized, style: .plain, target: self, action: #selector(cancel(_:)))
      }
    }
    super.willMove(toParent: parent)
  }

  @objc func cancel(_ sender: UIBarButtonItem) {
    view.endEditing(true)
    dismiss(animated: true, completion: nil)
  }

  override func makeCollectionViewLayout() -> UICollectionViewLayout {
    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.contentInsetsReference = .layoutMargins
    configuration.interSectionSpacing = 20

    let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
    return UICollectionViewCompositionalLayout(sectionProvider: { [unowned self] section, layoutEnvironment in
      let itemFractionalWidths = (0..<self.numberOfItems(inSection: section)).map { widthMultiplier(at: IndexPath(item: $0, section: section)) }
      let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, itemFractionalWidths: itemFractionalWidths, contentSpacing: 16)
      let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
      return layoutSection
    }, configuration: configuration)
  }

  override func collectionViewDidLoad() {
    super.collectionViewDidLoad()

    collectionView.keyboardDismissMode = .interactive
    collectionView.register(UICollectionViewCell.self, ofKind: UICollectionView.elementKindSectionHeader)
    collectionView.register(UICollectionViewCell.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemGroupedBackground
  }

  var numberOfSections: Int {
    fatalError()
  }

  func numberOfItems(inSection section: Int) -> Int {
    fatalError()
  }

  func content(at indexPath: IndexPath) -> UIContentConfiguration {
    fatalError()
  }

  func widthMultiplier(at indexPath: IndexPath) -> CGFloat {
    return 1
  }

  // MARK: UICollectionViewDataSource

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return numberOfSections
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfItems(inSection: section)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeue(UICollectionViewCell.self, for: indexPath)
    cell.contentConfiguration = content(at: indexPath)
    cell.backgroundConfiguration = .clear()
    return cell
  }

  //  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
  //    let view = collectionView.dequeue(UICollectionViewCell.self, ofKind: kind, for: indexPath)
  //    var content = UIListContentConfiguration.plainHeader()
  //    switch indexPath.section {
  //    case 0:
  //      content.text = "Name"
  //    case 1:
  //      content.text = "Number of Participants"
  //    case 2:
  //      content.text = "Frequency Type"
  //    case 3:
  //      content.text = "Start Date"
  //    default:
  //      fatalError()
  //    }
  //    view.contentConfiguration = content
  //    return view
  //  }

  // MARK: UIAdaptivePresentationControllerDelegate

  func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
    return !hasChanges
  }

  func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
    let alertController = UIAlertController(title: "Unsaved Changes", message: "Are you sure you want to discard changes?", preferredStyle: .alert, cancelActionTitle: "Cancel")
    alertController.addAction(title: "Discard", style: .destructive) { [unowned self] _ in
      self.dismiss(animated: true, completion: nil)
    }
    present(alertController, animated: true, completion: nil)
  }
}
