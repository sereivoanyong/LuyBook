//
//  Transaction.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import Foundation
import RealmSwift
import RealmSwiftKit

enum TransactionType: String, CaseIterable, PersistableEnum {

  case income
  case expense
}

final class Transaction: Object, _Identifiable {

  @Persisted(primaryKey: true)
  var _id: String = ObjectId.generate().stringValue

  @Persisted
  var _partition: String = app.currentUser!.id

  @Persisted
  var date: Date

  @Persisted
  var category: Category!

  @Persisted
  var account: Account!

  @Persisted
  var amount: Decimal128

  @Persisted
  var note: String?

  @Persisted
  var attachmentURLs: List<URL>

  @Persisted
  var tags: List<String>

  @Persisted
  var type: TransactionType

  @Persisted
  var creator: User.ID = app.currentUser!.id

  @Persisted
  var createdAt: Date
}

extension Transaction: Listable {

  static var localizedName: String {
    return "Transaction".localized
  }

  static var localizedCollectionName: String {
    return "Transactions".localized
  }
}
