//
//  AccountSettingsViewController.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/24/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

final class AccountSettingsViewController: ConfigurationsViewController {

  // MARK: Init / Deinit

  init(user: User) {
    super.init(nibName: nil, bundle: nil)

    title = "Account Settings".localized
    tabBarItem.image = UIImage(systemName: "line.3.horizontal")
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.removeBackButtonTitle()

    var linkedAccountItems: [ItemConfiguration] = []
    for providerType in IdentityProvider.allCases {
      let settings = LinkedAccountSettings(user: user, providerType: providerType, viewController: self)
      linkedAccountItems.append(.init(contentProvider: { ObjectContentConfiguration.linkedAccountSettingsList(settings) }))
    }

    sections = [
      .init(items: [
        .value(text: "Username".localized, secondaryText: user.customData["username"]??.stringValue),
        .value(text: "Email".localized, secondaryText: user.customData["email"]??.stringValue),
        .action(
          title: "action.change_%@".formatLocalized("Username".localized),
          selectionHandler: { _, _ in

          }
        ),
        .action(
          title: "action.change_%@".formatLocalized("Email".localized),
          selectionHandler: { _, _ in

          }
        ),
        .action(
          title: "action.change_%@".formatLocalized("Password".localized),
          selectionHandler: { _, _ in

          }
        )
      ]),
      .plain(headerText: "Linked Accounts".localized, items: linkedAccountItems),
      .init(items: [
        .action(
          title: "action.delete_account".localized,
          titleColor: .systemRed,
          selectionHandler: { _, _ in

          }
        )
      ])
    ]
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

  }
}
