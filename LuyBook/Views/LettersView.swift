//
//  LettersView.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import UIKit
import UIKitLayout
import SwiftKit

public struct Letters: Equatable {

  let string: String?
  let color: UIColor?
}

extension LettersView {

  final public class TextField: UITextField {

    var allowsEmojiOnly: Bool = true

    public override var textInputContextIdentifier: String? {
      if allowsEmojiOnly {
        return ""
      }
      return super.textInputContextIdentifier
    }

    public override var textInputMode: UITextInputMode? {
      if allowsEmojiOnly {
        return UITextInputMode.activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
      }
      return super.textInputMode
    }
  }
}

open class LettersView: UIView {

  public static let lettersDidChangeNotification = Notification.Name("LettersViewLettersDidChangeNotification")

  public let textField: TextField = {
    let textField = TextField(font: .system(size: 40), textAlignment: .center, textColor: .white).withAutoLayout
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    textField.tintColor = .white
    return textField
  }()

  /// Non-empty
  open var string: String? {
    get { return textField.text.nonEmpty }
    set { textField.text = newValue }
  }

  private var _color: UIColor?
  open var color: UIColor? {
    get { return _color }
    set { setColor(newValue) }
  }

  open var letters: Letters {
    get { return Letters(string: string.nonEmpty, color: color) }
    set { string = newValue.string; color = newValue.color }
  }

  open var isEditing: Bool = false

  open var size: CGSize = CGSize(width: 80, height: 80) {
    willSet {
      precondition(color == nil)
    }
    didSet {
      textField.font = .system(size: size.minDimension / 2)
    }
  }

  public override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    textField.delegate = self
    addSubview(textField)

    NSLayoutConstraint.activate((textField.anchors == anchors).all)
  }

  @objc private func textDidChange(_ textField: UITextField) {
    NotificationCenter.default.post(name: Self.lettersDidChangeNotification, object: self)
  }

  private func reloadBackground() {
    if let color = color {
      textField.background = UIImage(color: color, size: size, cornerRadius: size.maxDimension / 2)
    } else {
      textField.background = nil
    }
  }

  open override var intrinsicContentSize: CGSize {
    return size
  }

  open func setColor(_ newColor: UIColor?, notify: Bool = false) {
    _color = newColor
    reloadBackground()
    if notify {
      NotificationCenter.default.post(name: Self.lettersDidChangeNotification, object: self)
    }
  }
}

extension LettersView: UITextFieldDelegate {

  open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return isEditing
  }

  open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
    let textField = textField as! TextField
    if textField.allowsEmojiOnly {
      let newText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: replacementString)
      if newText.isSingleEmoji {
        return true
      }
      if replacementString.isSingleEmoji {
        defer {
          textField.text = replacementString
        }
        return false
      }
      return false
    }
    return true
  }
}

extension String {

  fileprivate var containsEmoji: Bool {
    return (self as NSString).value(forKey: "_containsEmoji") as? Bool ?? false
  }

  fileprivate var isSingleEmoji: Bool {
    return (self as NSString).value(forKey: "_isSingleEmoji") as? Bool ?? false
  }
}
