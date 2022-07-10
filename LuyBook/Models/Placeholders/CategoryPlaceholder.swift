//
//  CategoryPlaceholder.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import Foundation
import SwiftKit
import RealmSwift
import FirebaseStorage
import PropertyWrapperKit

final class CategoryPlaceholder: ObjectPlaceholder {

  typealias Object = Category

  @Published var name: String?

  @Published var imageLetters: Letters?

  @Published var parent: Category?

  @DelayedMutable var type: TransactionType

  func create(fetching realm: Realm?) -> Result<Object, ObjectValidationError> {
    guard let name = name else {
      return .failure(.init(title: "Name Required", errorDescription: nil, action: nil))
    }
    let object = Object()
    object.name = name
    object.imageLetters = imageLetters.map { .init(string: $0.string, color: $0.color) }
    object.parent = parent
    object.type = type
    return .success(object)
  }

  func copy() -> Self {
    let copied = Self()
    copied.copy(\.name, from: self)
    copied.copy(\.imageLetters, from: self)
    copied.copy(\.parent, from: self)
    copied.copy(\.type, from: self)
    return copied
  }

  static func hasChanges(lhs: CategoryPlaceholder, rhs: CategoryPlaceholder) -> Bool {
    return hasChange(lhs: lhs, rhs: rhs, at: \.name) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.imageLetters) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.parent) ||
    hasChange(lhs: lhs, rhs: rhs, at: \.type)
  }
}
