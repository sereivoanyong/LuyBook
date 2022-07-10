//
//  MoreViewController.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

final class MoreViewController: ConfigurationsViewController {

  let user: User
  let logOutSuccessHandler: () -> Void

  // MARK: Init / Deinit

  init(user: User, realm: Realm, logOutSuccessHandler: @escaping () -> Void) {
    self.user = user
    self.logOutSuccessHandler = logOutSuccessHandler
    super.init(nibName: nil, bundle: nil)

    title = "More".localized
    tabBarItem.image = UIImage(systemName: "line.3.horizontal")
    navigationItem.removeBackButtonTitle()

    let titles: [UIUserInterfaceStyle: String] = [
      .unspecified: "interface_style.unspecified".localized,
      .light: "interface_style.light".localized,
      .dark: "interface_style.dark".localized
    ]

    sections = [
      .init(headerContentProvider: { ObjectContentConfiguration<User>.profile(user) }, items: [
        .default(
          text: "Account Settings".localized,
          accessories: [.disclosureIndicator()],
          selectionHandler: { [unowned self] _, _ in
            let viewController = AccountSettingsViewController(user: user)
            self.navigationController?.pushViewController(viewController, animated: true)
          }
        )
      ]),
      .plain(headerText: nil, items: [
        .value(text: "Accounts".localized, secondaryText: nil, accessories: [.disclosureIndicator()]) { [unowned self] _, _ in
          let viewController = NotificationsViewController()
          self.navigationController?.pushViewController(viewController, animated: true)
        },
        .value(text: "Categories".localized, secondaryText: nil, accessories: [.disclosureIndicator()]) { [unowned self] _, _ in
          let viewController = CategoriesViewController(objects: realm.objects(Category.self))
          self.navigationController?.pushViewController(viewController, animated: true)
        }
      ]),
      .plain(headerText: nil, items: [
        .value(text: "Notifications".localized, secondaryText: nil, accessories: [.disclosureIndicator()]) { [unowned self] _, _ in
          let viewController = NotificationsViewController()
          self.navigationController?.pushViewController(viewController, animated: true)
        },
        .value(text: "Data & Storage".localized, secondaryText: nil, accessories: [.disclosureIndicator()]) { [unowned self] _, _ in
          let viewController = DataStorageViewController()
          self.navigationController?.pushViewController(viewController, animated: true)
        },
        .value(
          text: "Appearance".localized,
          secondaryTextProvider: { titles[Preferences.userInterfaceStyle] },
          accessories: [.disclosureIndicator()], selectionHandler: { [unowned self] collectionView, indexPath in
            let window = view.window!
            let styles: [UIUserInterfaceStyle] = [.unspecified, .light, .dark]
            let pickerViewController = PickerListViewController(items: styles, behavior: .pushWithSaveChangeOnSelectionThenPop(saveHandler: { style in
              Preferences.userInterfaceStyle = style
              window.overrideUserInterfaceStyle = style
              collectionView.reconfigureItems(at: [indexPath])
            }))
            pickerViewController.selectedItem = Preferences.userInterfaceStyle
            pickerViewController.contentProvider = { style in
              var content = UIListContentConfiguration.cell()
              content.text = titles[style]
              return content
            }
            pickerViewController.title = "Appearance".localized
            pickerViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pickerViewController, animated: true)
          }
        ),
        .value(
          text: "Language".localized,
          secondaryTextProvider: { Locale.selected.localizedLanguageCode },
          accessories: [.disclosureIndicator()],
          selectionHandler: { [unowned self] collectionView, indexPath in
            var localizations = Bundle.main.localizations
            localizations.removeAll("Base")
            let pickerViewController = PickerListViewController(items: localizations, behavior: .pushWithSaveChangeOnSelectionThenPop(saveHandler: { localization in
              Bundle.main.selectedLocalization = localization
              collectionView.reconfigureItems(at: [indexPath])
            }))
            pickerViewController.selectedItem = Bundle.main.selectedLocalization
            pickerViewController.contentProvider = { localization in
              var content = UIListContentConfiguration.subtitleCell()
              let locale = Locale(identifier: localization)
              content.text = locale.localizedLanguageCode
              let preferredLocalization = Bundle.main.preferredLocalizations.first
              let preferredLocale = preferredLocalization.map { Locale(identifier: $0) }
              if localization == preferredLocalization {
                content.secondaryText = "Default"
              } else {
                content.secondaryText = locale.languageCode.flatMap { preferredLocale?.localizedString(forLanguageCode: $0) } //locale.languageCode.flatMap { Locale(identifier: Bundle.main.selectedLocalization).localizedString(forLanguageCode: $0) }
              }
              return content
            }
            pickerViewController.title = "Language".localized
            pickerViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pickerViewController, animated: true)
          }
        )
      ]),
      .plain(
        headerText: "Help & Support",
        footerText: Bundle.main.displayNameWithShortVersionAndVersion().map { "\($0) by Sereivoan Yong" },
        items: [
          .default(text: "Privacy Policy".localized, accessories: [.disclosureIndicator()]),
          .default(text: "Bug Report", accessories: [.disclosureIndicator()])
        ]
      ),
      .init(items: [
        .action(
          title: "action.log_out".localized,
          titleColor: .systemRed,
          selectionHandler: { [unowned self] _, _ in
            self.promptLogOut()
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

  private func promptLogOut() {
    let alertController = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet, cancelActionTitle: "action.cancel".localized)
    alertController.addAction(title: "action.log_out".localized, style: .destructive) { [unowned self] _ in
      self.logOut()
    }
    present(alertController, animated: true)
  }

  private func logOut() {
    hud.show(animated: true)
    user.logOut { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print("Error logging out: \(error)")
      }
      DispatchQueue.main.async { [unowned self] in
        self.hud.hide(animated: true)
        self.logOutSuccessHandler()
      }
    }
    ProviderLoginManager.logOut()
  }
}

extension Locale {

  var localizedLanguageCode: String? {
    return languageCode.flatMap { localizedString(forLanguageCode: $0) }
  }
}
