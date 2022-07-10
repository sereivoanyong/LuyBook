//
//  SwiftKit.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/19/22.
//

import UIKit
import SwiftKit

extension UIImageProtocol {

  public init(dynamicColor: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat = 0) {
    self.init { traitCollection in
      let backgroundColor: UIColor
      if traitCollection.userInterfaceStyle != .dark {
        backgroundColor = .white
      } else {
        backgroundColor = .black
      }
      return UIImage(color: dynamicColor.resolvedColor(with: traitCollection).opaque(on: backgroundColor)!, size: size, cornerRadius: cornerRadius)
    }
  }
}

extension UIImage {

  public func centeredWithBackground(dynamicColor: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat = 0) -> UIImage {
    let rect = CGRect(origin: .zero, size: size)
    let imageSize = self.size
    let topLeftOrigin = CGPoint(x: rect.midX - (imageSize.width) / 2, y: rect.midY - (imageSize.height) / 2)
    return UIImage(size: size, opaque: false, scale: scale) { traitCollection, context in
      context.addPath(CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil))
      context.closePath()
      context.setFillColor(dynamicColor.resolvedColor(with: traitCollection).cgColor)
      context.fillPath()
      let image = withTintColor(traitCollection.userInterfaceStyle != .dark ? .black : .white, renderingMode: .alwaysTemplate)
      image.draw(at: topLeftOrigin)
    }
  }
}
