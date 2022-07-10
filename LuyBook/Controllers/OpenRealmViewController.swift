//
//  OpenRealmViewController.swift
//  TongTin
//
//  Created by Sereivoan Yong on 7/1/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

final class OpenRealmViewController: UIViewController {

  private var openTask: Realm.AsyncOpenTask!

  @IBOutlet weak private var progressView: UIProgressView!
  @IBOutlet weak private var textLabel: UILabel!

  let configuration: Realm.Configuration
  let successCompletion: (Realm) -> Void

  init(configuration: Realm.Configuration, successCompletion: @escaping (Realm) -> Void) {
    self.configuration = configuration
    self.successCompletion = successCompletion
    super.init(nibName: "\(OpenRealmViewController.self)", bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    deinitLog(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    openTask = Realm.asyncOpen(configuration: configuration, callbackQueue: .main) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let realm):
        self.configure(realm)
        self.successCompletion(realm)
      case .failure(let error):
        print(error)
      }
    }

    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useBytes, .useKB, .useMB]
    formatter.countStyle = .file
    openTask.addProgressNotification(queue: .main) { [weak self] progress in
      guard let self = self else { return }
      self.progressView.progress = Float(progress.fractionTransferred)

      let transferredBytesString = formatter.string(fromByteCount: Int64(progress.transferredBytes))
      let transferrableBytesString = formatter.string(fromByteCount: Int64(progress.transferrableBytes))
      self.textLabel.text = "\(transferredBytesString) of \(transferrableBytesString) downloaded..."
    }
  }

  private func configure(_ realm: Realm) {
    
  }
}
