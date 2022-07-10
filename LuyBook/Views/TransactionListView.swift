//
//  TransactionListView.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import UIKit
import SwiftKit
import RealmSwift
import PropertyWrapperKit

final class TransactionListView: UIView, ListContentView, NibLoadable {

  private let categoryIconSize = CGSize(width: 40, height: 40)

  @IBOutlet weak private var categoryIconImageView: UIImageView!
  @IBOutlet weak private var categoryNameLabel: UILabel!
  @IBOutlet weak private var noteLabel: UILabel!
  @IBOutlet weak private var amountLabel: UILabel!

  @DelayedBacked(ObjectContentConfiguration<Transaction>.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

  }

  private func apply(_ configuration: ObjectContentConfiguration<Transaction>) {
    let transaction = configuration.object
    categoryIconImageView.setImage(with: nil, placeholderColor: .systemFill, size: categoryIconSize, cornerRadius: categoryIconSize.maxDimension / 2)
    categoryNameLabel.text = transaction.category.name
    noteLabel.text = transaction.note
    amountLabel.text = NumberFormatter.currencyDisplayWithSign.string(from: transaction.amount)
  }
}

extension ObjectContentConfiguration {

  static func transactionList(_ object: Object) -> ObjectContentConfiguration<Object> where Object == Transaction {
    return Self.init(object: object) { configuration in
      return TransactionListView.loadFromNib().configure {
        $0.configuration = configuration
        $0.preservesSuperviewLayoutMargins = true
      }
    }
  }
}
