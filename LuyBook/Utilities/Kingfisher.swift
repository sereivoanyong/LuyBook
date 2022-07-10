//
//  Kingfisher.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/17/22.
//

import UIKit
import Kingfisher

private let defaultOptions: KingfisherOptionsInfo = [
  .cacheOriginalImage,
  .scaleFactor(UIScreen.main.scale),
  .cacheSerializer(FormatIndicatedCacheSerializer.png),
  .transition(.fade(0.2))
]

extension UIImageView {

  func setImage(
    with url: URL?,
    placeholderColor: UIColor,
    size: CGSize,
    cornerRadius: CGFloat
  ) {
    let placeholder = UIImage(dynamicColor: placeholderColor, size: size, cornerRadius: cornerRadius)
    var options: KingfisherOptionsInfo = defaultOptions
    let processor = ResizingImageProcessor(referenceSize: size, mode: .aspectFill) |> CroppingImageProcessor(size: size) |> RoundCornerImageProcessor(cornerRadius: cornerRadius)
    options.append(.processor(processor))
    kf.setImage(with: url, placeholder: placeholder, options: options, progressBlock: nil, completionHandler: nil)
  }
}
