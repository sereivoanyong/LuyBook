//
//  ListContentView.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/22/22.
//

import UIKit

protocol ListContentView: UIContentView {

  func makeConstraintsForSeparator() -> [NSLayoutConstraint]
}

extension ListContentView {

  func makeConstraintsForSeparator() -> [NSLayoutConstraint] {
    return []
  }
}
