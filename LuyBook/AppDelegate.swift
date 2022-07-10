//
//  AppDelegate.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import GoogleSignIn
import FacebookCore
import FirebaseCore
import KeyboardManager

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    configure(application, launchOptions: launchOptions)
    return true
  }

  func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if ApplicationDelegate.shared.application(application, open: url, options: options) {
      return true
    }
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    return false
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

  // MARK: Private

  private func configure(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    Bundle.swizzleForLocalization()
    ImageView.clearPickerResults()
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    GIDSignIn.sharedInstance.restorePreviousSignIn()
    FirebaseApp.configure()
    _ = KeyboardManager.shared
  }
}

private var paletteToolbarKey: Void?

extension UIViewController {

  var paletteToolbar: UIToolbar! {
    if let paletteToolbar = associatedObject(forKey: &paletteToolbarKey) as Toolbar? {
      return paletteToolbar
    }
    let toolbar = Toolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)).withAutoLayout
    toolbar.overrideBarPosition = .top
    setAssociatedObject(toolbar, forKey: &paletteToolbarKey)
    view.addSubview(toolbar)

    NSLayoutConstraint.activate([
      view.safeAreaLayoutGuide.topAnchor == toolbar.bottomAnchor,
      toolbar.leadingAnchor == view.leadingAnchor,
      view.trailingAnchor == toolbar.trailingAnchor
    ])
    return toolbar
  }
}

extension UISegmentedControl {

  static func makeForTransactionTypes(values: [TransactionType?], selectedValue: TransactionType?, changeHandler: @escaping (TransactionType?) -> Void) -> UISegmentedControl {
    var actions: [UIAction] = []
    for transactionType in values {
      actions.append(UIAction(title: transactionType.map { "\($0)".localized } ?? "All".localized) { _ in
        changeHandler(transactionType)
      })
    }
    let segmentedControl = UISegmentedControl(frame: .zero, actions: actions).withAutoLayout
    if let index = values.firstIndex(of: selectedValue) {
      segmentedControl.selectedSegmentIndex = index
    }
    return segmentedControl
  }
}

extension UINavigationItem {

  func configureBottomPinningView(_ pinningView: UIView) {
    let searchController = UISearchController(searchResultsController: nil)
    self.searchController = searchController
    hidesSearchBarWhenScrolling = false
    let searchBar = searchController.searchBar
    searchBar.perform(Selector(("_setSupportsDynamicType:")), with: false)
    for subview in searchBar.subviews {
      subview.alpha = 0
      subview.isHidden = true
      subview.removeFromSuperview()
    }
    let textField = searchBar.searchTextField
    textField.adjustsFontForContentSizeCategory = false
    textField.textColor = .clear
    textField.placeholder = nil
    textField.leftView = nil
    for subview in textField.subviews {
      subview.alpha = 0
      subview.isHidden = true
      subview.removeFromSuperview()
    }
    let targetView = textField.superview ?? textField
    targetView.addSubview(pinningView.withAutoLayout)
//    pinningView.heightAnchor.constraint(equalToConstant: 100).isActive = true
//    NSLayoutConstraint.activate((pinningView.anchors == targetView.anchors).all)
    NSLayoutConstraint.activate([
      pinningView.topAnchor == targetView.topAnchor + 1,
      targetView.bottomAnchor == pinningView.bottomAnchor + 16,
      pinningView.leadingAnchor == targetView.layoutMarginsGuide.leadingAnchor,
      targetView.layoutMarginsGuide.trailingAnchor == pinningView.trailingAnchor
    ])
    textField.removeFromSuperview()
    print(textField)
  }
}
