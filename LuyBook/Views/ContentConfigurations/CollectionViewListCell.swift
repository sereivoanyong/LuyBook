//
//  CollectionViewListCell.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/22/22.
//

import UIKit

class CollectionViewListCell: UICollectionViewListCell {

  private var constraintsForSeparator: [NSLayoutConstraint] = [] {
    didSet {
      NSLayoutConstraint.deactivate(oldValue)
      NSLayoutConstraint.activate(constraintsForSeparator)
    }
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    if let contentView = contentView as? ListContentView {
      constraintsForSeparator = contentView.makeConstraintsForSeparator()
    }
  }
}
