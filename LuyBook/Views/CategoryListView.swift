//
//  CategoryListView.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/9/22.
//

import UIKit
import SwiftKit
import RealmSwift
import PropertyWrapperKit

final class CategoryListView: UIView, ListContentView, NibLoadable {

  @IBOutlet weak private var lettersView: LettersView!
  @IBOutlet weak private var nameLabel: UILabel!

  @DelayedBacked(ObjectContentConfiguration<Category>.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    lettersView.size = CGSize(width: 40, height: 40)
  }

  private func apply(_ configuration: ObjectContentConfiguration<Category>) {
    let category = configuration.object
    lettersView.letters = .init(string: category.imageLetters?.string, color: category.imageLetters?.color ?? .systemFill)
    nameLabel.text = category.name
  }
}

extension ObjectContentConfiguration {

  static func categoryList(_ object: Object) -> ObjectContentConfiguration<Object> where Object == Category {
    return Self.init(object: object) { configuration in
      return CategoryListView.loadFromNib().configure {
        $0.configuration = configuration
        $0.preservesSuperviewLayoutMargins = true
      }
    }
  }
}
