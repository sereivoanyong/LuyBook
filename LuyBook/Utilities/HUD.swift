//
//  HUD.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/15/22.
//

import UIKit
import MBProgressHUD
import SwiftKit

#if DEBUG
final private class ProgressHUD: MBProgressHUD {

  deinit {
    deinitLog(self)
  }
}
#else
private typealias ProgressHUD = MBProgressHUD
#endif

extension UIViewController {

  private static var hudKey: Void?
  var hud: MBProgressHUD {
    if let hud = weakAssociatedObject(with: self, forKey: &Self.hudKey) as ProgressHUD? {
      if hud.superview == nil {
        view.window!.addSubview(hud)
      }
      return hud
    }
    let window = parent?.view ?? view.window!
    let hud = ProgressHUD(view: window)
    hud.backgroundView.color = UIColor(white: 0, alpha: 0.4)
    hud.removeFromSuperViewOnHide = true
    window.addSubview(hud)
    setWeakAssociatedObject(with: self, forKey: &Self.hudKey, value: hud)
    return hud
  }
}

final private class WeakObjectContainer {

  weak var object: AnyObject?

  init(_ object: AnyObject) {
    self.object = object
  }
}

private func weakAssociatedObject<T: AnyObject>(with object: NSObject, forKey key: UnsafeRawPointer) -> T? {
  if let container = objc_getAssociatedObject(object, key) as? WeakObjectContainer {
    return container.object as? T
  }
  return nil
}

private func setWeakAssociatedObject<T: AnyObject>(with object: NSObject, forKey key: UnsafeRawPointer, value: T?) {
  if let value = value {
    if let container = objc_getAssociatedObject(object, key) as? WeakObjectContainer {
      container.object = value
    } else {
      objc_setAssociatedObject(object, key, WeakObjectContainer(value), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  } else {
    objc_setAssociatedObject(object, key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
}
