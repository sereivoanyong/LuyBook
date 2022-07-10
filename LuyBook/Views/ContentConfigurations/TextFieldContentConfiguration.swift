//
//  TextContentConfiguration.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/16/22.
//

import UIKit
import UIKitSwift
import PropertyWrapperKit
import Combine

struct TextFieldContentConfiguration: UIContentConfiguration {

  let value: String?
  let receiveValue: (String?) -> Void

  func makeContentView() -> UIView & UIContentView {
    return TextFieldContentView().configure {
      $0.insets = Constants.textFieldInsets
      $0.configuration = self
    }
  }

  func updated(for state: UIConfigurationState) -> Self {
    return self
  }
}

final private class TextFieldContentView: TextField, UIContentView {

  private var cancellable: AnyCancellable?

  @DelayedBacked(TextFieldContentConfiguration.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  private func apply(_ configuration: TextFieldContentConfiguration) {
    text = configuration.value
    cancellable = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
      .map { ($0.object as! Self).text }
      .sink(receiveValue: configuration.receiveValue)
  }
}
