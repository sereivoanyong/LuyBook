//
//  Account.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import Foundation
import RealmSwift

final class Account: Object {

  @Persisted(primaryKey: true)
  var _id: String = ObjectId.generate().stringValue

  @Persisted
  var _partition: String

  @Persisted
  var name: String

  @Persisted
  var creator: String

  @Persisted
  var createdAt: Date
}
