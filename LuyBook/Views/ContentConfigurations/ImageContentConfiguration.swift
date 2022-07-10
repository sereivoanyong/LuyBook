//
//  ImageContentConfiguration.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/17/22.
//

import UIKit
import UIKitSwift
import PropertyWrapperKit
import Combine
import UniformTypeIdentifiers
import PhotosUI

struct ImageContentConfiguration: IdentifiableContentConfiguration, Identifiable {

  let id: UUID = UUID()
  let value: ImageSource?
  let receiveValue: (ImageSource?) -> Void
  unowned let viewController: UIViewController

  func makeContentView() -> UIView & UIContentView {
    return ImageContentView().configure {
      $0.configuration = self
    }
  }

  func updated(for state: UIConfigurationState) -> Self {
    return self
  }
}

final private class ImageContentView: UIView, UIContentView {

  let imageView: ImageView = .init().withAutoLayout

  @DelayedBacked(ImageContentConfiguration.self)
  var configuration: UIContentConfiguration {
    didSet {
      apply($configuration)
    }
  }

  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    imageView.imageSize = CGSize(width: 80, height: 80)
    imageView.imageCornerRadius = 10
    addSubview(imageView)

    NSLayoutConstraint.activate([
      imageView.leadingAnchor >= leadingAnchor,
      imageView.centerXAnchor == centerXAnchor,
      imageView.topAnchor == topAnchor,
      bottomAnchor == imageView.bottomAnchor,
    ])

    let backgroundView = UIControl().withAutoLayout
    backgroundView.backgroundColor = .secondarySystemGroupedBackground
    backgroundView.layer.setCorner(radius: 10, curve: .continuous)
    backgroundView.addTarget(self, action: #selector(showPicker(_:)), for: .touchUpInside)
    insertSubview(backgroundView, belowSubview: imageView)

    NSLayoutConstraint.activate((backgroundView.anchors == imageView.anchors).all)
  }

  @objc private func showPicker(_ sender: UIControl) {
    // https://www.kairadiagne.com/2020/11/04/adopting-the-new-photo-picker.html
    var configuration = PHPickerConfiguration(photoLibrary: .shared())
    configuration.selectionLimit = 1
    configuration.filter = .images

    let pickerViewController = PHPickerViewController(configuration: configuration)
    pickerViewController.delegate = self
    $configuration.viewController.present(pickerViewController, animated: true, completion: nil)
  }

  private func apply(_ configuration: ImageContentConfiguration) {
    imageView.imageSource = configuration.value
    imageView.transformsImageSource = true
    imageView.imageSourcePickerResultToFileURLCompletion = { pickerResult, fileURL in
      configuration.receiveValue(.fileURL(fileURL))
    }
  }
}

extension ImageContentView: PHPickerViewControllerDelegate {

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    imageView.imageSource = results.last.map { .pickerResult($0) }
  }
}
