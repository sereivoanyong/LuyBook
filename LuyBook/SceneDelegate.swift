//
//  SceneDelegate.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import UIKit
import RealmSwift
import FacebookCore

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let windowScene = scene as? UIWindowScene else { return }
    window = UIWindow(windowScene: windowScene)
    window?.overrideUserInterfaceStyle = Preferences.userInterfaceStyle
    if let user = app.currentUser {
      handleLogin(user: user, animated: false)
    } else {
      presentUnauthorizationViewController()
    }
    window?.makeKeyAndVisible()
  }

  func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
    guard let urlContext = urlContexts.first else {
      return
    }
    ApplicationDelegate.shared.application(.shared, open: urlContext.url, options: [:])
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }

  // MARK: Private

  private func handleLogin(user: User, animated: Bool) {
    user.refreshCustomData { result in
      switch result {
      case .success(let customData):
        print("User's custom data: \(customData)")
      case .failure(let error):
        print("Unable to refresh user custom data: \(error)")
      }
    }
    let configuration = user.configuration(partitionValue: .string(user.id))
    let openRealm: (Realm) -> Void = { [unowned self] realm in
      self.window!.setRootViewController(TabBarController(user: user, realm: realm, logOutSuccessHandler: { [unowned self] in
        self.presentUnauthorizationViewController(animated: true)
      }), animated: animated, duration: 0.4, options: .transitionCrossDissolve)
    }
    if Realm.fileExists(for: configuration) {
      let realm = try! Realm(configuration: configuration)
      openRealm(realm)
    } else {
      let openViewController = OpenRealmViewController(configuration: configuration, successCompletion: openRealm)
      window!.setRootViewController(openViewController, animated: animated, duration: 0.4, options: .transitionCrossDissolve)
    }
  }

  private func presentUnauthorizationViewController(animated: Bool = false) {
    let viewController = LogInViewController { [unowned self] user in
      self.handleLogin(user: user, animated: true)
    }
    window!.setRootViewController(viewController, animated: animated, duration: 0.4, options: .transitionCrossDissolve)
  }
}
