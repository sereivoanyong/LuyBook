//
//  MoreProfileHeaderView.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/24/22.
//

import UIKit
import SwiftKit
import RealmSwift
import PropertyWrapperKit

final class MoreProfileHeaderView: UIView, UIContentView, NibLoadable {

  let photoSize = CGSize(width: 120, height: 120)

  @IBOutlet weak private var photoImageView: UIImageView!
  @IBOutlet weak private var nameLabel: UILabel!

  @DelayedBacked(ObjectContentConfiguration<User>.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  private func apply(_ configuration: ObjectContentConfiguration<User>) {
    let user = configuration.object
    let data = user.customData
    photoImageView.setImage(with: data["photoURL"]??.urlValue, placeholderColor: .systemFill, size: photoSize, cornerRadius: photoSize.maxDimension/2)
    nameLabel.text = data["name"]??.stringValue ?? user.profile.name

  }

  @IBAction private func copyUsername(_ sender: UIButton) {
    guard let owningViewController = owningViewController else {
      return
    }
//    owningViewController.showToast(image: UIImage(systemName: "doc.on.doc.fill"), title: "Username Copied")
  }
}

extension ObjectContentConfiguration {

  static func profile(_ user: User) -> ObjectContentConfiguration<Object> where Object == User {
    return Self.init(object: user) { configuration in
      return MoreProfileHeaderView.loadFromNib().configure {
        $0.configuration = configuration
        $0.preservesSuperviewLayoutMargins = true
      }
    }
  }
}
