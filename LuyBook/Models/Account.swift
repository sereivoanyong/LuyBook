//
//  Account.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import Foundation
import RealmSwift
import RealmSwiftKit

final class Account: Object, _Identifiable {

  @Persisted(primaryKey: true)
  var _id: String = ObjectId.generate().stringValue

  @Persisted
  var _partition: String = app.currentUser!.id

  @Persisted
  var name: String

  @Persisted
  var creator: User.ID = app.currentUser!.id

  @Persisted
  var createdAt: Date
}

extension Account: Listable {

  static var localizedName: String {
    return "Account".localized
  }

  static var localizedCollectionName: String {
    return "Accounts".localized
  }
}
