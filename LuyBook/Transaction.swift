//
//  Transaction.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import Foundation
import RealmSwift

enum TransactionType: String, PersistableEnum {

  case income
  case expense
}

final class Transaction: Object {

  @Persisted(primaryKey: true)
  var _id: String = ObjectId.generate().stringValue

  @Persisted
  var _partition: String

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
  var creator: String

  @Persisted
  var createdAt: Date
}
