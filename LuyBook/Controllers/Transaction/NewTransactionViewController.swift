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
//    navigationItem.searchController = UISearchController(searchResultsController: nil).configure {
//      $0.searchBar.scopeButtonTitles = ["He", "Ho"]
//    }
//    let viewClass = NSClassFromString("CKNavigationBarCanvasView") as! UIView.Type
//    let view = viewClass.init()
    navigationItem.perform(Selector("px_setBannerView:"), with: UIView().withAutoLayout)

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

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

//    view.addSubview(segmentedControl)
//    NSLayoutConstraint.activate([
//      segmentedControl.topAnchor == view.safeAreaLayoutGuide.topAnchor,
//      segmentedControl.centerXAnchor == view.layoutMarginsGuide.centerXAnchor
//    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

//    navigationController?.navigationBar.prefersLargeTitles = true
//    collectionView.contentInset.top = 16 + segmentedControl.frame.height
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