//
//  DetailViewController.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/15/22.
//

import UIKit

protocol DetailViewController: UIViewController {

  associatedtype Object

  var object: Object { get }
}
