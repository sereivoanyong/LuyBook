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

extension UINavigationItem {

  func configureBottomPinningView(_ pinningView: UIView) {
    let searchController = UISearchController(searchResultsController: nil)
    self.searchController = searchController
    hidesSearchBarWhenScrolling = false
    let searchBar = searchController.searchBar
    searchBar.perform(Selector(("_setSupportsDynamicType:")), with: false)
    for subview in searchBar.subviews {
      subview.alpha = 0
      subview.isHidden = true
      subview.removeFromSuperview()
    }
    let textField = searchBar.searchTextField
    textField.adjustsFontForContentSizeCategory = false
    textField.textColor = .clear
    textField.placeholder = nil
    textField.leftView = nil
    for subview in textField.subviews {
      subview.alpha = 0
      subview.isHidden = true
      subview.removeFromSuperview()
    }
    let targetView = textField.superview ?? textField
    targetView.addSubview(pinningView.withAutoLayout)
//    pinningView.heightAnchor.constraint(equalToConstant: 100).isActive = true
//    NSLayoutConstraint.activate((pinningView.anchors == targetView.anchors).all)
    NSLayoutConstraint.activate([
      pinningView.topAnchor == targetView.topAnchor + 1,
      targetView.bottomAnchor == pinningView.bottomAnchor + 16,
      pinningView.leadingAnchor == targetView.layoutMarginsGuide.leadingAnchor,
      targetView.layoutMarginsGuide.trailingAnchor == pinningView.trailingAnchor
    ])
    textField.removeFromSuperview()
    print(textField)
  }
}

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

    let searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    let searchBar = searchController.searchBar
    searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    let targetView = searchBar.subviews[0]
    targetView.removeFromSuperview()
    targetView.translatesAutoresizingMaskIntoConstraints = false

    targetView.addSubview(segmentedControl)
    NSLayoutConstraint.activate([
      segmentedControl.topAnchor == targetView.topAnchor + 1,
      segmentedControl.leadingAnchor == targetView.leadingAnchor,
      targetView.trailingAnchor == segmentedControl.trailingAnchor,
      targetView.bottomAnchor == segmentedControl.bottomAnchor + 16,
    ])
    let v = UIView()
    v.frame.origin.y = 40
    navigationItem.setValue(v, forKey: "_canvasView")
//    for subview in searchBar.subviews[0].subviews where "\(type(of: subview))".hasSuffix("ContainerView") {
//      subview.removeFromSuperview()
//    }
//    let palette = searchBar.value(forKey: "_containingNavigationPalette") as! UIView?


//    let toolbar = Toolbar().withAutoLayout
//    toolbar.overrideBarPosition = .top
//    toolbar.scrollEdgeAppearance = UIToolbarAppearance().configure { $0.configureWithTransparentBackground() }
//    toolbar.compactScrollEdgeAppearance = UIToolbarAppearance().configure { $0.configureWithTransparentBackground() }
//    toolbar.sizeToFit()
//    view.addSubview(toolbar)
//    NSLayoutConstraint.activate([
//      view.safeAreaLayoutGuide.topAnchor == toolbar.bottomAnchor,
//      toolbar.leadingAnchor == view.leadingAnchor,
//      view.trailingAnchor == toolbar.trailingAnchor
//    ])
//
//    additionalSafeAreaInsets.top = toolbar.frame.height
//    collectionView.contentInset.top = 44
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
