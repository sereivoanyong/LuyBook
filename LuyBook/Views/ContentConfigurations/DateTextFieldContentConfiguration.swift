//
//  DateTextFieldContentConfiguration.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/16/22.
//

import UIKit
import UIKitSwift
import PropertyWrapperKit
import Combine

struct DateTextFieldContentConfiguration: UIContentConfiguration {

  let value: Date?
  let receiveValue: (Date?) -> Void

  func makeContentView() -> UIView & UIContentView {
    return DateTextFieldContentView().configure {
      $0.insets = Constants.textFieldInsets
      $0.configuration = self
    }
  }

  func updated(for state: UIConfigurationState) -> Self {
    return self
  }
}

final private class DateTextFieldContentView: DateTextField, UIContentView {

  private var cancellable: AnyCancellable?

  @DelayedBacked(DateTextFieldContentConfiguration.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  private func apply(_ configuration: DateTextFieldContentConfiguration) {
    date = configuration.value
    cancellable = NotificationCenter.default.publisher(for: DateTextField.dateDidChangeNotification)
      .map { ($0.object as! Self).date }
      .sink(receiveValue: configuration.receiveValue)
  }
}
