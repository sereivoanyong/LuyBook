//
//  NewCategoryViewController.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

final class NewCategoryViewController: NewObjectViewController<CategoryPlaceholder> {

  private var contents: [[IdentifiableContentConfiguration]]!

  lazy private var segmentedControl: UISegmentedControl = {
    var actions: [UIAction] = []
    let transactionTypes = TransactionType.allCases
    for transactionType in transactionTypes {
      actions.append(UIAction(title: "\(transactionType)") { [unowned self] _ in
        self.selectedTransactionType = transactionType
      })
    }
    let segmentedControl = UISegmentedControl(frame: .zero, actions: actions).withAutoLayout
    if let index = transactionTypes.firstIndex(of: selectedTransactionType) {
      segmentedControl.selectedSegmentIndex = index
    }
    return segmentedControl
  }()

  var selectedTransactionType: TransactionType = .expense {
    didSet {
      initialPlaceholder.type = selectedTransactionType
      placeholder.type = selectedTransactionType
    }
  }

  init(realm: Realm) {
    super.init(nibName: nil, bundle: nil)

    fetchingRealm = realm
    saveHandler = .add(to: realm)
    do {
      initialPlaceholder.type = selectedTransactionType
      placeholder.type = selectedTransactionType
    }

    contents = [
      [
        LettersContentConfiguration(value: placeholder.imageLetters) { [unowned self] value in
          self.placeholder.imageLetters = value
        }
      ], [
        TitleContentConfiguration<String>.textField(title: "Name".localized, value: placeholder.name) { [unowned self] value in
          self.placeholder.name = value
        }
      ]
    ]
  }

  deinit {
    deinitLog(self)
  }

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(segmentedControl)
    NSLayoutConstraint.activate([
      segmentedControl.topAnchor == view.safeAreaLayoutGuide.topAnchor,
      segmentedControl.centerXAnchor == view.layoutMarginsGuide.centerXAnchor
    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    collectionView.contentInset.top = 16 + segmentedControl.frame.height
  }

//  override func validated() throws -> Transaction {
//    if case .pickerResult = imageSource {
//      throw ObjectValidationError(title: "Resource Busy", errorDescription: "Please wait until the image has loaded.", action: nil)
//    }
//    return try super.validated()
//  }
//
//  override func widthMultiplier(at indexPath: IndexPath) -> CGFloat {
//    if indexPath.section == 4 {
//      return indexPath.item == 0 ? 3 : 4
//    }
//    return super.widthMultiplier(at: indexPath)
//  }

  override var numberOfSections: Int {
    return contents.count
  }

  override func numberOfItems(inSection section: Int) -> Int {
    return contents[section].count
  }

  override func content(at indexPath: IndexPath) -> UIContentConfiguration {
    return contents[indexPath.section][indexPath.item]
  }
}
