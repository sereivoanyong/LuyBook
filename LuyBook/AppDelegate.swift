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
