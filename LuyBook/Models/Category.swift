//
//  Category.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import Foundation
import RealmSwift
import RealmSwiftKit

final class Category: Object, _Identifiable {

  @Persisted(primaryKey: true)
  var _id: String = ObjectId.generate().stringValue

  @Persisted
  var _partition: String = app.currentUser!.id

  @Persisted
  var name: String

  @Persisted
  var imageLetters: ImageLetters!

  @Persisted
  var parent: Category?

  @Persisted
  var type: TransactionType
  
  @Persisted
  var creator: User.ID = app.currentUser!.id

  @Persisted
  var createdAt: Date
}

extension Category: Listable {

  static var localizedName: String {
    return "Category".localized
  }

  static var localizedCollectionName: String {
    return "Categories".localized
  }
}
