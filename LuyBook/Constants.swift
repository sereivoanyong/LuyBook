//
//  Constants.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import UIKit
import RealmSwift

let app = App(id: Constants.appId)

enum Constants {

  static let appId = "luybook-tovgp"

  static let googleClientID = "88208095518-liga8jcmsv1llrvpue1c47tl8t6d6rka.apps.googleusercontent.com"
  static let googleServerClientID = "88208095518-hudq0uotui5r7i5g4bhtiieb4css2127.apps.googleusercontent.com"

  static let systemTitleInsetsForInsetGroupedListStyle = UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20)
  static let textFieldInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
}

extension UIColor {

  static let accent = UIColor(named: "AccentColor")!
}

extension DateFormatter {

  static let display = DateFormatter(dateStyle: .medium, timeStyle: .short)
}

extension NumberFormatter {

  static let decimalDisplayForCurrency: NumberFormatter = {
    let formatter = NumberFormatter(numberStyle: .decimal)
    formatter.generatesDecimalNumbers = true
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 0
    formatter.locale = .enUS
    return formatter
  }()

  static let percentDisplay: NumberFormatter = {
    let formatter = NumberFormatter(numberStyle: .percent)
    formatter.generatesDecimalNumbers = true
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 0
    formatter.locale = .enUS
    return formatter
  }()


  static let currencyDisplay: NumberFormatter = {
    let formatter = NumberFormatter(numberStyle: .currency)
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 0
    formatter.locale = .enUS
    return formatter
  }()

  static let currencyDisplayWithSign: NumberFormatter = {
    let formatter = NumberFormatter(numberStyle: .currency)
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 0
    formatter.plusSign = "+"
    formatter.minusSign = "+"
    formatter.locale = .enUS
    return formatter
  }()
}

extension Locale {

  static let enUS = Locale(identifier: "en_US")
}

extension UIColor {

  static var systems: [UIColor] {
    return [
      .systemRed,
      .systemGreen,
      .systemBlue,
      .systemOrange,
      .systemYellow,
      .systemPink,
      .systemPurple,
      .systemTeal,
      .systemIndigo,
      .systemBrown,
      .systemMint,
      .systemCyan,
      .systemGray
    ]
  }
}
