//
//  ImageLetters.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import UIKit
import SwiftKit
import RealmSwift

public protocol FailableColorPersistable: FailableCustomPersistable where PersistedType == String {

}

extension FailableColorPersistable where Self: UIColor {

  public init?(persistedValue: PersistedType) {
    let color: UIColor?
    if persistedValue.hasPrefix("#") {
      color = UIColor(hexString: persistedValue)
    } else {
      switch persistedValue {
      case "systemRed":    color = .systemRed
      case "systemGreen":  color = .systemGreen
      case "systemBlue":   color = .systemBlue
      case "systemOrange": color = .systemOrange
      case "systemYellow": color = .systemYellow
      case "systemPink":   color = .systemPink
      case "systemPurple": color = .systemPurple
      case "systemTeal":   color = .systemTeal
      case "systemIndigo": color = .systemIndigo
      case "systemBrown":  color = .systemBrown
      case "systemMint":   color = .systemMint
      case "systemCyan":   color = .systemCyan
      case "systemGray":   color = .systemGray
      default:             color = nil
      }
    }
    if let color = color {
      self = color as! Self
    } else {
      return nil
    }
  }

  public var persistableValue: String {
    switch self {
    case .systemRed:    return "systemRed"
    case .systemRed:    return "systemRed"
    case .systemGreen:  return "systemGreen"
    case .systemBlue:   return "systemBlue"
    case .systemOrange: return "systemOrange"
    case .systemYellow: return "systemYellow"
    case .systemPink:   return "systemPink"
    case .systemPurple: return "systemPurple"
    case .systemTeal:   return "systemTeal"
    case .systemIndigo: return "systemIndigo"
    case .systemBrown:  return "systemBrown"
    case .systemMint:   return "systemMint"
    case .systemCyan:   return "systemCyan"
    case .systemGray:   return "systemGray"
    default:            return hexString()!
    }
  }
}

extension UIColor: FailableColorPersistable { }

final class ImageLetters: EmbeddedObject {

  @Persisted
  var string: String?

  @Persisted
  var color: UIColor?

  convenience init(string: String?, color: UIColor?) {
    self.init()
    self.string = string
    self.color = color
  }
}
