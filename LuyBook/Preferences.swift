//
//  Preferences.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import UIKit
import PropertyWrapperKit

enum Preferences {

  @UserDefault(key: "UserInterfaceStyle", default: .unspecified)
  static var userInterfaceStyle: UIUserInterfaceStyle
}
