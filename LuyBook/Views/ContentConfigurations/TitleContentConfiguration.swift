//
//  TitleContentConfiguration.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/16/22.
//

import UIKit
import UIKitSwift
import PropertyWrapperKit
import Combine

protocol IdentifiableContentConfiguration: UIContentConfiguration {

  var id: UUID { get }
}

struct TitleContentConfiguration<Value>: IdentifiableContentConfiguration, Identifiable {

  let id: UUID
  let title: String?
  let value: Value?
  let receiveValue: (Value?) -> Void
  let contentViewProvider: () -> TitleContentView<Value>

  init(id: UUID = UUID(), title: String?, value: Value?, receiveValue: @escaping (Value?) -> Void, contentViewProvider: @escaping () -> TitleContentView<Value>) {
    self.id = id
    self.title = title
    self.value = value
    self.receiveValue = receiveValue
    self.contentViewProvider = contentViewProvider
  }

  func makeContentView() -> UIView & UIContentView {
    return contentViewProvider().configure {
      $0.configuration = self
    }
  }

  func updated(for state: UIConfigurationState) -> Self {
    return self
  }
}

extension TitleContentConfiguration {

  static func textField(configurationHandler: ((TextField) -> Void)? = nil, title: String?, value: String?, receiveValue: @escaping (String?) -> Void) -> Self where Value == String {
    return Self.init(title: title, value: value, receiveValue: receiveValue) {
      let textField = TextField()
      textField.insets = Constants.textFieldInsets
      textField.clearButtonMode = .whileEditing
      configurationHandler?(textField)
      return TitleContentView<String>(valueView: textField) { textField, text, receiveValue, cancellable in
        textField.text = text
        cancellable = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField)
          .map { ($0.object as! TextField).text }
          .sink(receiveValue: receiveValue)
      }
    }
  }

  static func dateTextField(configurationHandler: ((DateTextField) -> Void)? = nil, title: String?, value: Date?, receiveValue: @escaping (Date?) -> Void) -> Self where Value == Date {
    return Self.init(title: title, value: value, receiveValue: receiveValue) {
      let textField = DateTextField()
      textField.insets = Constants.textFieldInsets
      textField.clearButtonMode = .whileEditing
      textField.datePicker.minimumDate = Date()
      configurationHandler?(textField)
      return TitleContentView<Date>(valueView: textField) { textField, date, receiveValue, cancellable in
        textField.date = date
        cancellable = NotificationCenter.default.publisher(for: DateTextField.dateDidChangeNotification, object: textField)
          .map { ($0.object as! DateTextField).date }
          .sink(receiveValue: receiveValue)
      }
    }
  }

  static func pickerTextField(configurationHandler: ((PickerTextField<Value>) -> Void)? = nil, title: String?, value: Value?, receiveValue: @escaping (Value?) -> Void) -> Self where Value: CaseIterable & Equatable, Value.AllCases == [Value] {
    return pickerTextField(configurationHandler: configurationHandler, title: title, values: Value.allCases, value: value, receiveValue: receiveValue)
  }

  static func pickerTextField(configurationHandler: ((PickerTextField<Value>) -> Void)? = nil, title: String?, values: [Value], value: Value?, receiveValue: @escaping (Value?) -> Void) -> Self where Value: Equatable {
    return Self.init(title: title, value: value, receiveValue: receiveValue) {
      let textField = PickerTextField<Value>()
      textField.setSourcePickerView(items: values)
      textField.insets = Constants.textFieldInsets
      textField.clearButtonMode = .whileEditing
      configurationHandler?(textField)
      return TitleContentView<Value>(valueView: textField) { textField, date, receiveValue, cancellable in
        textField.selectedItem = date
        cancellable = NotificationCenter.default.publisher(for: PickerTextField<Value>.selectedItemDidChangeNotification, object: textField)
          .map { ($0.object as! PickerTextField<Value>).selectedItem }
          .sink(receiveValue: receiveValue)
      }
    }
  }

  static func pickerTextField(configurationHandler: ((PickerTextField<Value>) -> Void)? = nil, title: String?, presentationHandler: @escaping (Value?, @escaping (Value?) -> Void) -> Void, value: Value?, receiveValue: @escaping (Value?) -> Void) -> Self where Value: Equatable {
    return Self.init(title: title, value: value, receiveValue: receiveValue) {
      let textField = PickerTextField<Value>()
      textField.setSourcePresentation(handler: presentationHandler)
      textField.insets = Constants.textFieldInsets
      textField.clearButtonMode = .whileEditing
      configurationHandler?(textField)
      return TitleContentView<Value>(valueView: textField) { textField, date, receiveValue, cancellable in
        textField.selectedItem = date
        cancellable = NotificationCenter.default.publisher(for: PickerTextField<Value>.selectedItemDidChangeNotification, object: textField)
          .map { ($0.object as! PickerTextField<Value>).selectedItem }
          .sink(receiveValue: receiveValue)
      }
    }
  }

  static func intTextField(configurationHandler: ((IntTextField) -> Void)? = nil, title: String?, value: Int?, receiveValue: @escaping (Int?) -> Void) -> Self where Value == Int {
    return Self.init(title: title, value: value, receiveValue: receiveValue) {
      let textField = IntTextField()
      textField.insets = Constants.textFieldInsets
      textField.transformer = .default
      textField.clearButtonMode = .whileEditing
      return TitleContentView<Int>(valueView: textField) { textField, value, receiveValue, cancellable in
        textField.value = value
        cancellable = NotificationCenter.default.publisher(for: IntTextField.valueDidChangeNotification, object: textField)
          .map { ($0.object as! IntTextField).value }
          .sink(receiveValue: receiveValue)
      }
    }
  }

  static func decimalTextField(title: String?, value: Decimal?, receiveValue: @escaping (Decimal?) -> Void) -> Self where Value == Decimal {
    return Self.init(title: title, value: value, receiveValue: receiveValue) {
      let textField = DecimalTextField()
      textField.insets = Constants.textFieldInsets
      textField.transformer = .formatted(.decimalDisplayForCurrency)
      textField.clearButtonMode = .whileEditing
      return TitleContentView<Decimal>(valueView: textField) { textField, value, receiveValue, cancellable in
        textField.value = value
        cancellable = NotificationCenter.default.publisher(for: DecimalTextField.valueDidChangeNotification, object: textField)
          .map { ($0.object as! DecimalTextField).value }
          .sink(receiveValue: receiveValue)
      }
    }
  }
}

final class TitleContentView<Value>: UIView, UIContentView {

  @DelayedBacked(TitleContentConfiguration<Value>.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  private var cancellable: AnyCancellable?

  // .SFUI-Semibold 15.00pt
  let titleLabel = UILabel(font: .system(size: 15, weight: .semibold), textColor: .secondaryLabel).withAutoLayout

  let valueView: UIView

  let applyValueHandler: (UIView, Value?, @escaping (Value?) -> Void, inout AnyCancellable?) -> Void

  init<ValueView: UIView>(valueView: ValueView, applyValueHandler: @escaping (ValueView, Value?, @escaping (Value?) -> Void, inout AnyCancellable?) -> Void) {
    self.valueView = valueView.withAutoLayout
    self.applyValueHandler = {
      applyValueHandler($0 as! ValueView, $1, $2, &$3)
    }
    super.init(frame: .zero)

    addSubview(titleLabel)
    addSubview(valueView)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor == topAnchor + 4,
      titleLabel.leadingAnchor == leadingAnchor + 20,
      trailingAnchor == titleLabel.trailingAnchor + 20,

      valueView.topAnchor == titleLabel.bottomAnchor + 4,
      valueView.leadingAnchor == leadingAnchor,
      trailingAnchor == valueView.trailingAnchor,
      bottomAnchor == valueView.bottomAnchor
    ])

    let backgroundView = UIView().withAutoLayout
    backgroundView.backgroundColor = .secondarySystemGroupedBackground
    backgroundView.layer.setCorner(radius: 10, curve: .continuous)
    insertSubview(backgroundView, belowSubview: valueView)

    NSLayoutConstraint.activate((backgroundView.anchors == valueView.anchors).all)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func apply(_ configuration: TitleContentConfiguration<Value>) {
    titleLabel.text = configuration.title
    applyValueHandler(valueView, configuration.value, configuration.receiveValue, &cancellable)
  }
}
