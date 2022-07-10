//
//  TransactionsViewController.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

class TransactionsViewController: RealmCollectionCollectionViewController<Transaction>, UICollectionViewDataSource, UICollectionViewDelegate {

  lazy private var addButton: UIButton = makeAddButton { [unowned self] _ in
    let viewController = NewTransactionViewController(realm: self.objects.realm!)
    self.present(viewController.embeddingInNavigationController(), animated: true)
  }.withAutoLayout

  // MARK: Init / Deinit

  override init<C: RealmCollection & _ObjcBridgeable>(objects: C) where C.Element == Transaction {
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

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

//    collectionView.contentInset.bottom =
  }

  override func configure(_ cell: UICollectionViewListCell, with object: Transaction, at indexPath: IndexPath) {
    let content = ObjectContentConfiguration.transactionList(object)
    cell.contentConfiguration = content
  }

//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    collectionView.deselectItem(at: indexPath, animated: true)
//
//    let viewController = ParticipantsViewController(objects: object.participants)
//    navigationController?.pushViewController(viewController, animated: true)
//  }
}
