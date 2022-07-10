//
//  AccountsViewController.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/11/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

class AccountsViewController: RealmCollectionCollectionViewController<Account>, UICollectionViewDataSource, UICollectionViewDelegate {

  lazy private var addButton: UIButton = makeAddButton { [unowned self] _ in
    let viewController = NewCategoryViewController(realm: self.objects.realm!)
    self.present(viewController.embeddingInNavigationController(), animated: true)
  }.withAutoLayout

  // MARK: Init / Deinit

  override init<C: RealmCollection & _ObjcBridgeable>(objects: C) where C.Element == Account {
    super.init(objects: objects.sorted(by: \.createdAt, ascending: false))

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

  override func configure(_ cell: UICollectionViewListCell, with object: Account, at indexPath: IndexPath) {
//    let content = ObjectContentConfiguration.categoryList(object)
//    cell.contentConfiguration = content
  }
}
