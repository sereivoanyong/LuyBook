//
//  NewTransactionViewController.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

final class NewTransactionViewController: NewObjectViewController<TransactionPlaceholder> {

  private var contents: [[IdentifiableContentConfiguration]]!

  lazy private var segmentedControl: UISegmentedControl = .makeForTransactionTypes(values: TransactionType.allCases, selectedValue: selectedTransactionType) { [unowned self] transactionType in
    self.selectedTransactionType = transactionType!
  }

  var selectedTransactionType: TransactionType = .expense {
    didSet {
      initialPlaceholder.type = selectedTransactionType
      placeholder.type = selectedTransactionType
    }
  }

  // MARK: Init / Deinit

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
        TitleContentConfiguration<Decimal>.decimalTextField(title: "Amount".localized, value: placeholder.amount) { [unowned self] value in
          self.placeholder.amount = value
        }
      ], [
        TitleContentConfiguration<Date>.dateTextField(title: "Date".localized, value: placeholder.date) { [unowned self] value in
          self.placeholder.date = value
        }
      ], [
        TitleContentConfiguration<String>.textField(title: "Note".localized, value: placeholder.note) { [unowned self] value in
          self.placeholder.note = value
        }
      ]
    ]
  }

  deinit {
    deinitLog(self)
  }

  // MARK: Collection View Lifecycle

  override func collectionViewDidLoad() {
    super.collectionViewDidLoad()


  }

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    paletteToolbar.items = [
      .flexibleSpace(),
      UIBarButtonItem(customView: segmentedControl),
      .flexibleSpace()
    ]
    additionalSafeAreaInsets.top = paletteToolbar.frame.height
  }

  // MARK: Data Source

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
