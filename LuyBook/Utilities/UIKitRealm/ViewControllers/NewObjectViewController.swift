//
//  NewObjectViewController.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/15/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

class NewObjectViewController<Placeholder: ObjectPlaceholder>: FormViewController {

  struct SaveHandler {

    let handle: (Object) throws -> Void

    static func add(to realm: Realm, block: ((Object) -> Void)? = nil) -> SaveHandler where Object: RealmSwift.Object {
      return .init { object in
        try realm.write {
          realm.add(object)
          block?(object)
        }
      }
    }
  }

  typealias Object = Placeholder.Object

  var initialPlaceholder: Placeholder = .init()

  var placeholder: Placeholder = .init() {
    didSet {
      initialPlaceholder = placeholder.copy()
    }
  }

  override var hasChanges: Bool {
    return Placeholder.hasChanges(lhs: placeholder, rhs: initialPlaceholder)
  }

  var fetchingRealm: Realm?

  var saveHandler: SaveHandler?

  override init(nibName: String?, bundle: Bundle?) {
    super.init(nibName: nibName, bundle: bundle)

    if let objectType = Object.self as? Listable.Type {
      title = "New %@".formatLocalized(objectType.localizedName)
    }
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "action.done".localized, style: .done, target: self, action: #selector(done(_:)))
    navigationItem.removeBackButtonTitle()
  }

  func validated() throws -> Object {
    switch placeholder.create(fetching: fetchingRealm) {
    case .success(let object):
      return object
    case .failure(let error):
      throw error
    }
  }

  @objc func done(_ sender: UIBarButtonItem) {
    view.endEditing(true)

    do {
      let object = try validated()
      let isApplyingAsynchronously = placeholder.applyAsynchronously(object: object, failureHandler: { error in
        print(error)
      }, completion: { [weak self] object in
        guard let self = self else { return }
        self.hud.hide(animated: true)
        self.saveAndDismiss(object)
      })
      if isApplyingAsynchronously {
        hud.show(animated: true)
      } else {
        self.saveAndDismiss(object)
      }

    } catch {
      let error = error as! ObjectValidationError
      let alertController = UIAlertController(title: error.title, message: error.errorDescription, preferredStyle: .alert, cancelActionTitle: "OK")
      if let action = error.action {
        alertController.addAction(action)
      }
      present(alertController, animated: true, completion: nil)
    }
  }

  /// Called after create and async apply
  private func saveAndDismiss(_ object: Object) {
    guard let handler = saveHandler else {
      fatalError()
    }
    do {
      try handler.handle(object)
//      showToast(image: UIImage(systemName: "checkmark"), title: "Shadow Participant Created")
      dismiss(animated: true, completion: nil)
    } catch {
      let alertController = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert, cancelActionTitle: "OK")
      present(alertController, animated: true, completion: nil)
    }
  }
}
