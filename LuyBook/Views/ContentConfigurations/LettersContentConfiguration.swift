//
//  LettersContentConfiguration.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/10/22.
//

import UIKit
import UIKitSwift
import PropertyWrapperKit
import Combine

struct LettersContentConfiguration: IdentifiableContentConfiguration, Identifiable {

  let id: UUID = UUID()
  let value: Letters?
  let receiveValue: (Letters?) -> Void

  func makeContentView() -> UIView & UIContentView {
    return LettersContentView().configure {
      $0.configuration = self
    }
  }

  func updated(for state: UIConfigurationState) -> Self {
    return self
  }
}

final class LettersContentView: UIView, UIContentView {

  private var cancellable: Cancellable?

  let lettersView: LettersView = .init().withAutoLayout

  @DelayedBacked(LettersContentConfiguration.self)
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
    lettersView.size = CGSize(width: 80, height: 80)
    lettersView.isEditing = true
    addSubview(lettersView)

    NSLayoutConstraint.activate([
      lettersView.leadingAnchor >= leadingAnchor,
      lettersView.centerXAnchor == centerXAnchor,
      lettersView.topAnchor == topAnchor,
      bottomAnchor == lettersView.bottomAnchor,
    ])

//    let backgroundView = UIControl().withAutoLayout
//    backgroundView.backgroundColor = .secondarySystemGroupedBackground
//    backgroundView.layer.setCorner(radius: 10, curve: .continuous)
//    insertSubview(backgroundView, belowSubview: lettersView)
//
//    NSLayoutConstraint.activate((backgroundView.anchors == lettersView.anchors).all)
  }

  private func apply(_ configuration: LettersContentConfiguration) {
    lettersView.letters = configuration.value ?? .init(string: nil, color: .systemBlue)
    cancellable = NotificationCenter.default.publisher(for: LettersView.lettersDidChangeNotification, object: lettersView)
      .map { ($0.object as! LettersView).letters }
      .sink(receiveValue: configuration.receiveValue)
  }
}
