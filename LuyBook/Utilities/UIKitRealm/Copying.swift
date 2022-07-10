//
//  Copying.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/17/22.
//

import Foundation

protocol Copying {

  func copy() -> Self
}

extension Copying {

  func copy<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, from target: Self) {
    self[keyPath: keyPath] = target[keyPath: keyPath]
  }
}
