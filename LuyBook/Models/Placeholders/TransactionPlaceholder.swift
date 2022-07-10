//
//  TransactionPlaceholder.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import Foundation
import SwiftKit
import RealmSwift
import FirebaseStorage
import PropertyWrapperKit

final class TransactionPlaceholder: ObjectPlaceholder {

  typealias Object = Transaction

  @Published var date: Date?

  @Published var category: Category?

  @Published var account: Account?

  @Published var amount: Decimal?

  @Published var note: String?

  @Published var tags: [String]?

  @DelayedMutable var type: TransactionType

  func create(fetching realm: Realm?) -> Result<Object, ObjectValidationError> {
    guard let date = date else {
      return .failure(.init(title: "Date Required", errorDescription: nil, action: nil))
    }
    guard let category = category else {
      return .failure(.init(title: "Category Required", errorDescription: nil, action: nil))
    }
    guard let account = account else {
      return .failure(.init(title: "Account Required", errorDescription: nil, action: nil))
    }
    guard let amount = amount else {
      return .failure(.init(title: "Amount Required", errorDescription: nil, action: nil))
    }
    guard amount > 0 else {
      return .failure(.init(title: "Invalid Amount", errorDescription: nil, action: nil))
    }
    let object = Object()
    object.date = date
    object.category = category
    object.account = account
    object.amount = amount.decimal128Value
    object.note = note
    if let tags = tags {
      object.tags.append(objectsIn: tags)
    }
    object.type = type
    return .success(object)
  }

  func copy() -> Self {
    let copied = Self()
    copied.copy(\.date, from: self)
    copied.copy(\.category, from: self)
    copied.copy(\.account, from: self)
    copied.copy(\.amount, from: self)
    copied.copy(\.note, from: self)
    copied.copy(\.tags, from: self)
    copied.copy(\.type, from: self)
    return copied
  }

  static func hasChanges(lhs: TransactionPlaceholder, rhs: TransactionPlaceholder) -> Bool {
    return hasChange(lhs: lhs, rhs: rhs, at: \.date) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.category) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.account) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.amount) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.note) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.tags) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.type)
  }
}
