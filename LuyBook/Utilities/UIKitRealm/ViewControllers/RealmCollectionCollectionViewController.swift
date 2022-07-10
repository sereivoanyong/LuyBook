//
//  RealmCollectionCollectionViewController.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/13/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

protocol PickerViewControllerProtocol: UIViewController {

  var selectedObject: Object? { get set }
}

protocol AnyPickerContentViewController: CollectionViewController {

  var selectedObjects_: [Any] { get set }
  var selectionHandler_: Any? { get set }
}

protocol PickerContentViewController: AnyPickerContentViewController {

  associatedtype Object

  static var pickerViewControllerClass: PickerViewController<Object>.Type { get }

  func makePicker() -> PickerViewController<Object>
}

extension PickerContentViewController {

  static var pickerViewControllerClass: PickerViewController<Object>.Type {
    return PickerViewController<Object>.self
  }

  func makePicker() -> PickerViewController<Object> {
    let pickerViewController = Self.pickerViewControllerClass.init(contentViewController: self)
    return pickerViewController
  }

  var picker: PickerViewController<Object>? {
    var target = parent
    while let current = target {
      if let current = target as? PickerViewController<Object> {
        return current
      }
      target = current.parent
    }
    return nil
  }
}

class RealmCollectionCollectionViewController<Object: RealmSwift.ObjectBase & RealmCollectionValue>: CollectionViewController, PickerContentViewController {

  private var notificationToken: NotificationToken?

  let initialObjects: AnyRealmCollection<Object>

  private(set) var objects: AnyRealmCollection<Object> {
    didSet {
      observe()
      objectsDidChange()
      collectionView.reloadData()
    }
  }

  init<C: RealmCollection & _ObjcBridgeable>(objects: C) where C.Element == Object {
    let objects = objects as? AnyRealmCollection<Object> ?? .init(objects)
    self.initialObjects = objects
    self.objects = objects
    super.init(nibName: nil, bundle: nil)

    if let objectType = Object.self as? Listable.Type {
      title = objectType.localizedCollectionName
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func collectionViewDidLoad() {
    super.collectionViewDidLoad()

    collectionView.register(UICollectionViewListCell.self)
    observe()
  }

  func observe() {
    guard isCollectionViewLoaded else {
      return
    }
    notificationToken = objects.observe(on: .main) { [unowned self] changes in
      switch changes {
      case .initial:
        initiallyReloadData()
        objectsDidChange()

      case .update(_, let deletions, let insertions, let modifications):
        collectionView.performBatchUpdates({
          collectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: 0) })
          collectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: 0) })
          collectionView.reloadItems(at: modifications.map { IndexPath(item: $0, section: 0) })
        }, completion: nil)
        objectsDidChange()

      case .error(let error):
        fatalError("\(error)")
      }
    }
  }

  func initiallyReloadData() {
    collectionView.reloadData()
  }

  func objectsDidChange() {

  }

  func setNeedsObjectsUpdate() {
    objects = filterObjects(initial: initialObjects)
  }

  func filterObjects(initial objects: AnyRealmCollection<Object>) -> AnyRealmCollection<Object> {
    return objects
  }

  func configureSearchController(placeholder: String) {
    let searchController = UISearchController(searchResultsController: nil)
    let searchBar = searchController.searchBar
    searchBar.placeholder = placeholder
    navigationItem.searchController = searchController
  }

  func makeAddButton(actionHandler: @escaping (UIAction) -> Void) -> UIButton {
    var configuration = UIButton.Configuration.filled()
    configuration.buttonSize = .large
    configuration.cornerStyle = .capsule
    return UIButton(configuration: configuration, primaryAction: UIAction(image: UIImage(systemName: "plus"), handler: actionHandler))
  }

  func detailViewController(for object: Object) -> UIViewController? {
    return nil
  }

  var numberOfObjects: Int {
    return objects.count
  }

  func firstIndexPath(for targetObject: Object) -> IndexPath? {
    for (index, object) in objects.enumerated() {
      if object == targetObject {
        return IndexPath(item: index, section: 0)
      }
    }
    return nil
  }

  func object(at indexPath: IndexPath) -> Object {
    return objects[indexPath.item]
  }

  func accessories(at indexPath: IndexPath) -> [UICellAccessory] {
    return []
  }

  func configure(_ cell: UICollectionViewListCell, with object: Object, at indexPath: IndexPath) {

  }

  @objc(collectionView:numberOfItemsInSection:)
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfObjects
  }

  @objc(collectionView:cellForItemAtIndexPath:)
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeue(UICollectionViewListCell.self, for: indexPath)
    if parent is PickerViewController<Object> {
      cell.configurationUpdateHandler = { cell, state in
        (cell as! UICollectionViewListCell).accessories = state.isSelected ? [.checkmark()] : [.disclosureIndicator()]
      }
    }
    configure(cell, with: object(at: indexPath), at: indexPath)
    return cell
  }

  @objc(collectionView:didSelectItemAtIndexPath:)
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let object = object(at: indexPath)
    if parent is PickerViewController<Object> {
      selectionHandler?(object)
      if let navigationController = navigationController, navigationController.viewControllers.first != self {
        navigationController.popViewController(animated: true)
      } else {
        dismiss(animated: true)
      }
    } else {
      collectionView.deselectItem(at: indexPath, animated: true)
      if let detailViewController = detailViewController(for: object) {
        navigationController?.pushViewController(detailViewController, animated: true)
      }
    }
  }

  var selectedObjects_: [Any] {
    get { return selectedObjects }
    set { selectedObjects = newValue as! [Object] }
  }

  var selectionHandler_: Any? {
    get { return selectionHandler }
    set { selectionHandler = newValue as! ((Object?) -> Void)? }
  }

  var selectedObjects: [Object] {
    get {
      return (collectionView.indexPathsForSelectedItems ?? []).map(object(at:))
    }
    set {
      let indexPaths = Set<IndexPath>(collectionView.indexPathsForSelectedItems ?? [])
      let newIndexPaths = Set<IndexPath>(newValue.compactMap(firstIndexPath(for:)))
      guard indexPaths != newIndexPaths else {
        return
      }
      collectionView.performBatchUpdates {
        for indexPath in newIndexPaths.subtracting(indexPaths) {
          collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        for indexPath in indexPaths.subtracting(newIndexPaths) {
          collectionView.deselectItem(at: indexPath, animated: false)
        }
      }
    }
  }

  var selectionHandler: ((Object) -> Void)?

  static var pickerViewControllerClass: UIViewController.Type {
    return PickerViewController<Object>.self
  }
}

final class PickerViewController<Object>: UIViewController {

  var selectedObject: Object? {
    get { contentViewController.selectedObjects_.first as! Object? }
    set { contentViewController.selectedObjects_ = newValue.map { [$0] } ?? [] }
  }

  var selectionHandler: ((Object?) -> Void)? {
    get { return contentViewController.selectionHandler_ as! ((Object?) -> Void)? }
    set { contentViewController.selectionHandler_ = newValue }
  }

  let contentViewController: AnyPickerContentViewController

  init(contentViewController: AnyPickerContentViewController) {
    self.contentViewController = contentViewController
    super.init(nibName: nil, bundle: nil)

    if let objectType = Object.self as? Listable.Type {
      title = "action.select_%@".formatLocalized(objectType.localizedName)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    addChildIncludingView(contentViewController) { view, childView in
      childView.frame = view.bounds
      childView.autoresizingMask = .flexibleSize
      view.addSubview(childView)
    }
  }

  override func willMove(toParent parent: UIViewController?) {
    if let navigationController = parent as? UINavigationController {
      if navigationController.viewControllers.first == self {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "action.cancel".localized, style: .plain, target: self, action: #selector(dismiss(_:)))
      }
    }
    super.willMove(toParent: parent)
  }
}
