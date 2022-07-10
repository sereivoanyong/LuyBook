//
//  LinkedAccountSettingsListView.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/24/22.
//

import UIKit
import SwiftKit
import RealmSwift
import PropertyWrapperKit

struct LinkedAccountSettings {

  let user: User
  let providerType: IdentityProvider
  unowned let viewController: UIViewController
}

final class LinkedAccountSettingsListView: UIView, UIContentView, NibLoadable {

  private var providerLoginManager: ProviderLoginManager?

  @IBOutlet weak private var nameLabel: UILabel!
  @IBOutlet weak private var toggleButton: UIButton!

  @DelayedBacked(ObjectContentConfiguration<LinkedAccountSettings>.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  private func apply(_ configuration: ObjectContentConfiguration<LinkedAccountSettings>) {
    let settings = configuration.object
    nameLabel.text = "\(settings.providerType)"
    let isLinked = settings.user.identity(for: settings.providerType) != nil
    var content = UIButton.Configuration.tinted()
    content.title = isLinked ? "Linked".localized : "action.link".localized
    content.buttonSize = .mini
    content.cornerStyle = .medium
    content.imagePadding = 4
    toggleButton.configuration = content
    toggleButton.isEnabled = !isLinked
  }

  @IBAction private func toggle(_ sender: UIButton) {
    sender.showsActivityIndicator = true

    let settings = $configuration.object
    let loginManager = ProviderLoginManager()
    loginManager.logIn(with: settings.providerType, presentingViewController: settings.viewController) { [weak self] result in
      guard let self = self else { return }
      self.providerLoginManager = nil
      switch result {
      case .success(let credentials):
        settings.user.linkUser(credentials: credentials) { [unowned sender] result in
          DispatchQueue.main.async {
            sender.showsActivityIndicator = false

            switch result {
            case .success(let user):
              assert(user.identity(for: settings.providerType) != nil)
              sender.setTitle("Linked".localized, for: .normal, animated: false)

            case .failure(let error):
              print("Error linking with credentials: \(error)")
              settings.viewController.presentAlert(title: "Unable to Link", message: error.localizedDescription, cancelActionTitle: "action.cancel".localized)
            }
          }
        }

      case .failure(let error):
        sender.showsActivityIndicator = false
        settings.viewController.presentAlert(title: "Unable to Log In", message: error.localizedDescription, cancelActionTitle: "OK".localized, animated: true, completion: nil)

      case .cancellation:
        sender.showsActivityIndicator = false
      }
    }
    self.providerLoginManager = loginManager
  }
}

extension ObjectContentConfiguration {

  static func linkedAccountSettingsList(_ settings: Object) -> ObjectContentConfiguration<Object> where Object == LinkedAccountSettings {
    return Self.init(object: settings) { configuration in
      return LinkedAccountSettingsListView.loadFromNib().configure {
        $0.configuration = configuration
        $0.preservesSuperviewLayoutMargins = true
      }
    }
  }
}
