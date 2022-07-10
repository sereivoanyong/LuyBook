//
//  IntTextFieldContentConfiguration.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/16/22.
//

import UIKit
import UIKitSwift
import PropertyWrapperKit
import Combine

struct IntTextFieldContentConfiguration: UIContentConfiguration {

  let value: Int?
  let receiveValue: (Int?) -> Void

  func makeContentView() -> UIView & UIContentView {
    return IntTextFieldContentView().configure {
      $0.insets = Constants.textFieldInsets
      $0.transformer = .custom({ String($0) }, { Int($0) })
      $0.configuration = self
    }
  }

  func updated(for state: UIConfigurationState) -> Self {
    return self
  }
}

final private class IntTextFieldContentView: IntTextField, UIContentView {

  private var cancellable: AnyCancellable?

  @DelayedBacked(IntTextFieldContentConfiguration.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  private func apply(_ configuration: IntTextFieldContentConfiguration) {
    value = configuration.value
    cancellable = NotificationCenter.default.publisher(for: IntTextField.valueDidChangeNotification)
      .map { ($0.object as! Self).value }
      .sink(receiveValue: configuration.receiveValue)
  }
}
