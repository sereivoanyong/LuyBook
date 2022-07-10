//
//  TabBarController.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

final class TabBarController: UITabBarController {

  let user: User
  let realm: Realm
  let logOutSuccessHandler: () -> Void

  // MARK: Init / Deinit

  init(user: User, realm: Realm, logOutSuccessHandler: @escaping () -> Void) {
    self.user = user
    self.realm = realm
    self.logOutSuccessHandler = logOutSuccessHandler
    super.init(nibName: nil, bundle: nil)
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

    viewControllers = [
      TransactionsViewController(objects: realm.objects(Transaction.self)),
//      PotsViewController(user: user, objects: realm.objects(Pot.self)),
//      BidsViewController(objects: realm.objects(Bid.self)),
//      ContributionsViewController(objects: realm.objects(Contribution.self)),
      MoreViewController(user: user, realm: realm, logOutSuccessHandler: logOutSuccessHandler)
    ].map {
      $0.embeddingInNavigationController(configurationHandler: { navigationController in
        navigationController.navigationBar.prefersLargeTitles = true
      })
    }
  }
}
