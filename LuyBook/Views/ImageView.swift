//
//  ImageView.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/17/22.
//

import UIKit
import PhotosUI
import UniformTypeIdentifiers
import Kingfisher

//pickerResult.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//  print("loadObject", image)
//}
//pickerResult.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
//  print("loadDataRepresentation", data.flatMap { UIImage(data: $0) })
//}
//pickerResult.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] fileURL, error in
//  print("loadFileRepresentation", fileURL.flatMap { UIImage(contentsOfFile: $0.path) })
//}
//pickerResult.itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] fileURL, error in
//  print("loadItem", (fileURL as? URL).flatMap { UIImage(contentsOfFile: $0.path) })
//}

public enum ImageSource: Equatable {

  case pickerResult(PHPickerResult)
  case fileURL(URL)
  case data(Data)
  case image(UIImage)

  public var pickerResult: PHPickerResult? {
    if case .pickerResult(let pickerResult) = self {
      return pickerResult
    }
    return nil
  }

  public var fileURL: URL? {
    if case .fileURL(let fileURL) = self {
      return fileURL
    }
    return nil
  }
}

open class ImageView: UIImageView {

  open var imageSource: ImageSource? {
    didSet {
      guard imageSource != oldValue else {
        return
      }
      guard let imageSource = imageSource else {
        return
      }
      if case .activity = kf.indicatorType { } else {
        kf.indicatorType = .activity
      }
      kf.indicator?.stopAnimatingView()
      switch imageSource {
      case .pickerResult(let pickerResult):
        image = nil
        kf.indicator?.startAnimatingView()
        pickerResult.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] temporaryFileURL, error in
          // Check if the image source has not changed
          guard let self = self, self.imageSource == .pickerResult(pickerResult) else { return }
          let fileURL = Self.copyForPickerResult(fileURL: temporaryFileURL)
          DispatchQueue.main.async { [unowned self] in
            self.kf.indicator?.stopAnimatingView()
            switch Result(fileURL, error)! {
            case .success(let fileURL):
              if self.transformsImageSource {
                self.imageSource = .fileURL(fileURL)
                self.imageSourcePickerResultToFileURLCompletion?(pickerResult, fileURL)
              } else {
                self.image = UIImage(contentsOfFile: fileURL.path)
              }
            case .failure(let error):
#if DEBUG
              print("Unable to load selected photo: \(error)")
#else
              break
#endif
            }
          }
        }
      case .fileURL(let fileURL):
        if var image = UIImage(contentsOfFile: fileURL.path) {
          var imageProcessor: ImageProcessor?
          if let imageSize = imageSize {
            let p = ResizingImageProcessor(referenceSize: imageSize, mode: .aspectFill) |> CroppingImageProcessor(size: imageSize)
            imageProcessor = imageProcessor.map { $0 |> p } ?? p
          }
          if imageCornerRadius > 0 {
            let p = RoundCornerImageProcessor(cornerRadius: imageCornerRadius)
            imageProcessor = imageProcessor.map { $0 |> p } ?? p
          }
          if let imageProcessor = imageProcessor {
            image = imageProcessor.process(item: .image(image), options: .init([.scaleFactor(UIScreen.main.scale)]))!
          }
          self.image = image
        } else {
          self.image = nil
        }

      case .data(let data):
        image = UIImage(data: data)
      case .image(let image):
        self.image = image
      }
    }
  }

  open var transformsImageSource: Bool = true

  open var imageSourcePickerResultToFileURLCompletion: ((PHPickerResult, URL) -> Void)?

  open var imageSize: CGSize?

  open override var intrinsicContentSize: CGSize {
    return imageSize ?? super.intrinsicContentSize
  }

  open var imageCornerRadius: CGFloat = 0
}

extension ImageView {

  static let fileManager: FileManager = .default

  static let pickerResultsDirectoryURL: URL = fileManager.temporaryDirectory.appendingPathComponent("picker_results", isDirectory: true)

  static func copyForPickerResult(fileURL: URL?) -> URL? {
    guard let fileURL = fileURL else {
      return nil
    }
    if !fileManager.fileExists(atPath: pickerResultsDirectoryURL.path) {
      try! fileManager.createDirectory(at: pickerResultsDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }
    let newFileURL = pickerResultsDirectoryURL.appendingPathComponent(fileURL.lastPathComponent)
    if fileManager.fileExists(atPath: newFileURL.path) {
      try? fileManager.removeItem(at: newFileURL)
    }
    try! fileManager.copyItem(at: fileURL, to: newFileURL)
    return newFileURL
  }

  static func clearPickerResults() {
    guard let fileURLs = try? fileManager.contentsOfDirectory(at: pickerResultsDirectoryURL, includingPropertiesForKeys: nil) else {
      return
    }
    for fileURL in fileURLs {
      try? fileManager.removeItem(at: fileURL)
    }
  }
}
