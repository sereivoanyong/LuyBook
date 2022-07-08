//
//  RealmSwift.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import Foundation
import Realm
import RealmSwift

extension URL: FailableCustomPersistable {

  public typealias PersistedType = String

  public init?(persistedValue: PersistedType) {
    self.init(string: persistedValue)
  }

  public var persistableValue: PersistedType {
    return absoluteString
  }
}

extension Decimal {

  @inlinable
  public var decimal128Value: Decimal128 {
    return Decimal128(number: self as NSDecimalNumber)
  }
}

extension NumberFormatter {

  @inlinable
  final public func string(from decimal128: Decimal128) -> String? {
    return string(from: decimal128.decimalValue)
  }
}

extension RealmCollection {

  public func distinct<S: Sequence>(by keyPaths: S) -> Results<Element> where Element: ObjectBase, S.Iterator.Element == PartialKeyPath<Element> {
    return distinct(by: keyPaths.map(_name(for:)))
  }

  public func observeCount(on queue: DispatchQueue? = nil, _ block: @escaping (Int) -> Void) -> NotificationToken {
    return observe(on: queue) { change in
      switch change {
      case .initial(let objects):
        block(objects.count)
      case .update(let objects, _, _, _):
        guard !objects.isInvalidated else {
          return
        }
        block(objects.count)
      case .error:
        break
      }
    }
  }

  public func observe(keyPaths: [PartialKeyPath<Element>] = [], collectionView: UICollectionView, section: Int) -> NotificationToken where Element: ObjectBase {
    return observe(keyPaths: keyPaths.map(_name(for:)), on: .main) { change in
      switch change {
      case .initial:
        break

      case .update(let objects, let deletions, let insertions, let modifications):
        guard !objects.isInvalidated else {
          return
        }
        collectionView.performBatchUpdates({
          collectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: section) })
          collectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: section) })
          collectionView.reloadItems(at: modifications.map { IndexPath(item: $0, section: section) })
        }, completion: nil)

      case .error(let error):
        print(error)
      }
    }
  }
}

extension AnyBSON {

  @inlinable
  public var urlValue: URL? {
    if let stringValue = stringValue {
      return URL(string: stringValue)
    }
    return nil
  }
}


//extension User {
//
//  final func identity(for providerType: ProviderType) -> RLMUserIdentity? {
//    if let identity = identities.first(where: { ProviderType(rawValue: $0.providerType) == providerType }) {
//      return identity
//    }
//    return nil
//  }
//}

extension User: Identifiable {

}

extension NSObjectProtocol where Self: Object {

  public func find<Object: RealmSwift.Object & Identifiable>(_ keyPath: KeyPath<Self, Object.ID>) -> Object? {
    guard let realm = realm else {
      return nil
    }
    return realm.object(ofType: Object.self, forPrimaryKey: self[keyPath: keyPath])
  }

//  func find(_ keyPath: KeyPath<Self, User.ID>) -> UserData? {
//    guard let realm = realm else {
//      return nil
//    }
//    return realm.object(ofType: UserData.self, forPrimaryKey: self[keyPath: keyPath])
//  }
}
