//
//  ObjectContentConfiguration.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/18/22.
//

import UIKit

struct ObjectContentConfiguration<Object>: UIContentConfiguration {

  let object: Object
  let contentViewProvider: (ObjectContentConfiguration<Object>) -> UIView & UIContentView

  init(object: Object, contentViewProvider: @escaping (ObjectContentConfiguration<Object>) -> UIView & UIContentView) {
    self.object = object
    self.contentViewProvider = contentViewProvider
  }

  func makeContentView() -> UIView & UIContentView {
    return contentViewProvider(self)
  }

  func updated(for state: UIConfigurationState) -> Self {
    return self
  }
}
