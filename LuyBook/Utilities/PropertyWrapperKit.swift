//
//  PropertyWrapperKit.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/13/22.
//

import UIKit
import PropertyWrapperKit

extension DelayedBacked {

  init(_ valueType: Value.Type) where Value: UIContentConfiguration, Wrapped == UIContentConfiguration {
    self.init()
  }
}

@propertyWrapper
struct Backed<Wrapped: AnyObject, Value: AnyObject> {

  init(_ valueType: Value.Type) {
  }

  weak var value: Value!

  var wrappedValue: Wrapped! {
    get { return value as? Wrapped }
    set { value = newValue as? Value }
  }

  var projectedValue: Value {
    return value
  }
}
