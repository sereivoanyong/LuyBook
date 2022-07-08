//
//  Profile.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import Foundation
import RealmSwift

final class Profile: Object {

  @Persisted(primaryKey: true)
  var _id: String = ObjectId.generate().stringValue

  @Persisted
  var _partition: String

  @Persisted
  var name: String?

  @Persisted
  var email: String?

  @Persisted
  var createdAt: Date
}
