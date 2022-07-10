//
//  ObjectPlaceholder.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/17/22.
//

import UIKit
import SwiftKit
import RealmSwift

protocol ObjectPlaceholder: ObservableObject, Copying {

  associatedtype Object: RealmSwift.ObjectBase

  init()

  func create(fetching realm: Realm?) -> Result<Object, ObjectValidationError>

  /// `failureHandler` can get called multiple times.
  /// `completion` give us a chance to modify or swap with different object
  func applyAsynchronously(object: Object, failureHandler: @escaping (Error) -> Void, completion: @escaping (Object) -> Void) -> Bool

  static func hasChanges(lhs: Self, rhs: Self) -> Bool
}

extension ObjectPlaceholder {

  func applyAsynchronously(object: Object, failureHandler: @escaping (Error) -> Void, completion: @escaping (Object) -> Void) -> Bool {
    return false
  }

  static func hasChange<C: Collection & Equatable>(lhs: Self, rhs: Self, at keyPath: KeyPath<Self, C?>) -> Bool {
    return lhs[keyPath: keyPath].nonEmpty != rhs[keyPath: keyPath].nonEmpty
  }

  static func hasChange<A: AdditiveArithmetic>(lhs: Self, rhs: Self, at keyPath: KeyPath<Self, A?>) -> Bool {
    return lhs[keyPath: keyPath].nonZero != rhs[keyPath: keyPath].nonZero
  }

  static func hasChange<T: Equatable>(lhs: Self, rhs: Self, at keyPath: KeyPath<Self, T>) -> Bool {
    return lhs[keyPath: keyPath] != rhs[keyPath: keyPath]
  }
}

struct ObjectValidationError: LocalizedError {

  let title: String
  let errorDescription: String?
  let action: UIAlertAction?
}
