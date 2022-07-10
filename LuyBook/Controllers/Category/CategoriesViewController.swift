//
//  CategoriesViewController.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

class CategoriesViewController: RealmCollectionCollectionViewController<Category>, UICollectionViewDataSource, UICollectionViewDelegate {

  lazy private var segmentedControl: UISegmentedControl = .makeForTransactionTypes(values: [nil] + TransactionType.allCases, selectedValue: selectedTransactionType) { [unowned self] transactionType in
    self.selectedTransactionType = transactionType
  }

  lazy private var addButton: UIButton = makeAddButton { [unowned self] _ in
    let viewController = NewCategoryViewController(realm: self.objects.realm!)
    self.present(viewController.embeddingInNavigationController(), animated: true)
  }.withAutoLayout

  var selectedTransactionType: TransactionType? = nil {
    didSet {
      setNeedsObjectsUpdate()
    }
  }
  
  // MARK: Init / Deinit

  override init<C: RealmCollection & _ObjcBridgeable>(objects: C) where C.Element == Category {
    super.init(objects: objects.sorted(by: \.createdAt, ascending: false))

    navigationItem.titleView = segmentedControl
  }

  deinit {
    deinitLog(self)
  }

  // MARK: Collection View Lifecycle

  override func makeCollectionViewLayout() -> UICollectionViewLayout {
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.backgroundColor = .clear
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    return layout
  }

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    view.addSubview(addButton)

    NSLayoutConstraint.activate([
      view.layoutMarginsGuide.trailingAnchor == addButton.trailingAnchor,
      view.layoutMarginsGuide.bottomAnchor == addButton.bottomAnchor
    ])
  }

  override func filterObjects(initial objects: AnyRealmCollection<Category>) -> AnyRealmCollection<Category> {
    var objects = super.filterObjects(initial: objects)
    if let selectedTransactionType = selectedTransactionType {
      objects = .init(objects.filter("\(_name(for: \Category.type)) == %@", selectedTransactionType))
    }
    return objects
  }

  override func configure(_ cell: UICollectionViewListCell, with object: Category, at indexPath: IndexPath) {
    let content = ObjectContentConfiguration.categoryList(object)
    cell.contentConfiguration = content
  }
}
