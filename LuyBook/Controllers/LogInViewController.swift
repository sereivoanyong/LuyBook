//
//  LogInViewController.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/15/22.
//

import UIKit
import UIKitSwift
import UIKitLayout
import SwiftKit
import RealmSwift
import Kingfisher
import FacebookLogin
import GoogleSignIn
import MBProgressHUD

final class LogInViewController: UIViewController {

  @IBOutlet weak private var emailTextField: TextField!
  @IBOutlet weak private var passwordTextField: TextField!

  @IBOutlet weak private var logInButton: UIButton!

  @IBOutlet weak private var providerStackView: UIStackView!

  private var providerLoginManager: ProviderLoginManager?

  let successHandler: (User) -> Void

  // MARK: Init / Deinit

  init(successHandler: @escaping (User) -> Void) {
    self.successHandler = successHandler
    super.init(nibName: "\(LogInViewController.self)", bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    deinitLog(self)
  }

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    emailTextField.layer.setCorner(radius: 8, masks: [.layerMinXMinYCorner, .layerMaxXMinYCorner], continuous: true)
    emailTextField.layer.shouldRasterize(to: .main)
    emailTextField.insets = Constants.textFieldInsets

    passwordTextField.layer.setCorner(radius: 8, masks: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], continuous: true)
    passwordTextField.layer.shouldRasterize(to: .main)
    passwordTextField.insets = Constants.textFieldInsets

    logInButton.setBackgroundImage(color: logInButton.backgroundColor, cornerRadius: 8, renderingMode: .alwaysTemplate, for: .normal)
    logInButton.backgroundColor = nil

    let activityIndicatorConfigurationHandler: (UIActivityIndicatorView) -> Void = { activityIndicatorView in
      activityIndicatorView.color = (activityIndicatorView.color ?? .secondaryLabel).dynamicReversed()
    }
    let loginButtonConfigurationHandler: (UIButton) -> Void = { button in
      button.activityIndicatorUserInteractionLevel = .window()
      button.activityIndicatorConfigurationHandler = activityIndicatorConfigurationHandler
    }
    loginButtonConfigurationHandler(logInButton)

#if DEBUG
    emailTextField.text = "sereivoanyong@gmail.com"
    passwordTextField.text = "Admin@123"
#endif

    do {
      let logInButton = makelogInButton(
        image: UIImage(named: "Sign in with Apple/Logo Square"),
        action: #selector(logInWithApple(_:))
      )
      providerStackView.addArrangedSubview(logInButton)
    }
    do {
      let resourceBundle = Bundle(for: GIDSignIn.self).bundle(name: "GoogleSignIn_GoogleSignIn")
      let logInButton = makelogInButton(
        image: UIImage(named: "google", in: resourceBundle, compatibleWith: traitCollection)?.withRenderingMode(.alwaysOriginal),
        action: #selector(logInWithGoogle(_:))
      )
      providerStackView.addArrangedSubview(logInButton)
    }
    do {
      _ = FBLoginButton.swizzler
      let button = FBLoginButton(frame: .zero)
      let accentColor = button.value(forKey: "defaultBackgroundColor") as? UIColor ?? .integer(red: 24, green: 119, blue: 242, alpha: 100)
      let logInButton = makelogInButton(
        image: button.currentImage?.kf.overlaying(with: accentColor, fraction: 0).withRenderingMode(.alwaysOriginal),
        action: #selector(logInWithFacebook(_:))
      )
      providerStackView.addArrangedSubview(logInButton)
    }

    for button in providerStackView.arrangedSubviews as! [UIButton] {
      loginButtonConfigurationHandler(button)
    }
  }

  private func makelogInButton(image: UIImage?, action: Selector) -> UIButton {
    let logInButton = UIButton(type: .system, image: image, target: self, action: action)
    logInButton.tintColor = .label
    logInButton.setBackgroundImage(color: .black, cornerRadius: 8, renderingMode: .alwaysTemplate, for: .normal)
    logInButton.widthAnchor.equalTo(constant: 44)
    logInButton.heightAnchor.equalTo(constant: 44)
    return logInButton
  }

  @IBAction private func logInEmailPassword(_ sender: UIButton) {
    view.endEditing(true)

    guard let email = emailTextField.text.nonEmpty else {
      return
    }
    guard let password = passwordTextField.text.nonEmpty else {
      return
    }
    appLogIn(credentials: .emailPassword(email: email, password: password), sender: sender)
  }

  @objc private func logInWithApple(_ sender: UIButton) {
    logIn(with: .apple, sender: sender)
  }

  @objc private func logInWithFacebook(_ sender: UIButton) {
    logIn(with: .facebook, sender: sender)
  }

  @objc private func logInWithGoogle(_ sender: UIButton) {
    logIn(with: .google, sender: sender)
  }

  private func logIn(with provider: IdentityProvider, sender: UIButton) {
    view.endEditing(true)

    sender.showsActivityIndicator = true
    let loginManager = ProviderLoginManager()
    loginManager.logIn(with: provider, presentingViewController: self) { [unowned self] result in
      self.providerLoginManager = nil
      switch result {
      case .success(let credentials):
        self.appLogIn(credentials: credentials, sender: sender)
      case .failure(let error):
        sender.showsActivityIndicator = false
        print("Error logging in with \(provider): \(error)")
        self.presentAlert(title: "Unable to Log In", message: error.localizedDescription, cancelActionTitle: "OK", animated: true, completion: nil)
      case .cancellation:
        sender.showsActivityIndicator = false
      }
    }
    providerLoginManager = loginManager
  }

  private func appLogIn(credentials: Credentials, sender: UIButton) {
    sender.showsActivityIndicator = true
    app.login(credentials: credentials) { [unowned self] result in
      DispatchQueue.main.async { [unowned self] in
        sender.showsActivityIndicator = false
        switch result {
        case .success(let user):
          self.successHandler(user)

        case .failure(let error):
          print("Error logging in using credentials: \(error) \(credentials)")
          self.presentAlert(title: "Unable to Log In", message: error.localizedDescription, cancelActionTitle: "OK", animated: true, completion: nil)
        }
      }
    }
  }
}

extension Bundle {

  fileprivate func bundle(name: String) -> Bundle? {
    guard let path = path(forResource: name, ofType: "bundle") else {
      return nil
    }
    return Bundle(path: path)
  }
}

extension FBLoginButton {

  fileprivate static let swizzler: Void = swizzle()

  private static func swizzle() {
    class_exchangeInstanceMethodImplementations(self, Selector(("defaultFont")), #selector(_swizzledDefaultFont))
  }

  @objc private func _swizzledDefaultFont() -> UIFont {
    return .system(size: 19)
  }
}
