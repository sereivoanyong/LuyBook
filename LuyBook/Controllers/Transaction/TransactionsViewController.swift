//
//  TransactionsViewController.swift
//  LuyBook
//
//  Created by Sereivoan Yong on 7/8/22.
//

import UIKit
import UIKitSwift
import SwiftKit
import RealmSwift

enum DurationComponent: String, CaseIterable {

  case day = "d"
  case week
  case month
  case year

  func dateRange(in calendar: Calendar) -> ClosedRange<Date> {
    let date = Date()
    let startDate, endDate: Date
    switch self {
    case .day:
      startDate = calendar.startOfDay(for: date)
      endDate = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startDate)!

    case .week:
      // https://stackoverflow.com/a/35687720/11235826
      startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
      endDate = calendar.date(byAdding: DateComponents(day: 7, second: -1), to: startDate)!

    case .month:
      // https://stackoverflow.com/a/20158940/11235826
      startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
      endDate = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: startDate)!

    case .year:
      startDate = calendar.date(from: calendar.dateComponents([.year], from: date))!
      endDate = calendar.date(byAdding: DateComponents(year: 1, second: -1), to: startDate)!
    }
    return startDate...endDate
  }
}

class TransactionsViewController: RealmCollectionCollectionViewController<Transaction>, UICollectionViewDataSource, UICollectionViewDelegate {

  lazy private var durationButton: UIButton = makeDurationButton()
  lazy private var addButton: UIButton = makeAddButton { [unowned self] _ in
    let viewController = NewTransactionViewController(realm: self.objects.realm!)
    self.present(viewController.embeddingInNavigationController(), animated: true)
  }.withAutoLayout

  let dateFormatter = DateFormatter()

  var selectedDurationComponent: DurationComponent {
    didSet {
      dateRange = selectedDurationComponent.dateRange(in: calendar)
    }
  }

  let calendar: Calendar
  var dateRange: ClosedRange<Date> {
    didSet {
      durationButton.setNeedsUpdateConfiguration()
    }
  }

  // MARK: Init / Deinit

  override init<C: RealmCollection & _ObjcBridgeable>(objects: C) where C.Element == Transaction {
    calendar = .current
    selectedDurationComponent = .month
    dateRange = selectedDurationComponent.dateRange(in: calendar)
    super.init(objects: objects.sorted(by: \.createdAt, ascending: false))

    configureSearchController(placeholder: "Search tags")
  }

  deinit {
    deinitLog(self)
  }

  // MARK: Collection View Lifecycle

  override func makeCollectionViewLayout() -> UICollectionViewLayout {
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.backgroundColor = .clear
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    return layout
  }
  
  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    paletteToolbar.items = [
      UIBarButtonItem(customView: durationButton),
      .flexibleSpace(),
      makePreviousButtonItem(),
      makeNextButtonItem()
    ]

//    additionalSafeAreaInsets.top = paletteToolbar.frame.height

    view.addSubview(addButton)

    NSLayoutConstraint.activate([
      view.layoutMarginsGuide.trailingAnchor == addButton.trailingAnchor,
      view.layoutMarginsGuide.bottomAnchor == addButton.bottomAnchor
    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

//    collectionView.contentInset.bottom =
  }

  private func title(for dateRange: ClosedRange<Date>) -> String {
    switch selectedDurationComponent {
    case .day:
      dateFormatter.dateFormat = "EEE MMM d"
      return dateFormatter.string(from: dateRange.lowerBound)
    case .week:
      dateFormatter.dateFormat = "EEE MMM d"
      return "\(dateFormatter.string(from: dateRange.lowerBound)) - \(dateFormatter.string(from: dateRange.upperBound))"
    case .month:
      dateFormatter.dateFormat = "MMM yyyy"
      return dateFormatter.string(from: dateRange.lowerBound)
    case .year:
      dateFormatter.dateFormat = "yyyy"
      return dateFormatter.string(from: dateRange.lowerBound)
    }
  }

  private func makeDurationButton() -> UIButton {
    var configuration = UIButton.Configuration.plain()
    configuration.image = UIImage(systemName: "chevron.right")
    configuration.imagePlacement = .trailing
    configuration.contentInsets = .zero
    let button = UIButton(configuration: configuration).withAutoLayout
    button.configurationUpdateHandler = { [unowned self] button in
      var configuration = button.configuration ?? .plain()
      configuration.attributedTitle = .init(self.title(for: self.dateRange), attributes: .init([.foregroundColor: UIColor.label]))
      button.configuration = configuration
    }
    func makeMenu() -> UIMenu {
      var actions: [UIAction] = []
      for component in DurationComponent.allCases {
        actions.append(UIAction(title: "\(component)".localized, state: component == selectedDurationComponent ? .on : .off) { [unowned self] _ in
          self.selectedDurationComponent = component
          button.menu = makeMenu()
        })
      }
      return UIMenu(children: actions)
    }
    button.menu = makeMenu()
    button.showsMenuAsPrimaryAction = true
    return button
  }

  private func makePreviousButtonItem() -> UIBarButtonItem {
    return UIBarButtonItem(primaryAction: UIAction(image: UIImage(systemName: "chevron.left")) { _ in

    })
  }

  private func makeNextButtonItem() -> UIBarButtonItem {
    return UIBarButtonItem(primaryAction: UIAction(image: UIImage(systemName: "chevron.right")) { _ in

    })
  }

  override func configure(_ cell: UICollectionViewListCell, with object: Transaction, at indexPath: IndexPath) {
    let content = ObjectContentConfiguration.transactionList(object)
    cell.contentConfiguration = content
  }

//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    collectionView.deselectItem(at: indexPath, animated: true)
//
//    let viewController = ParticipantsViewController(objects: object.participants)
//    navigationController?.pushViewController(viewController, animated: true)
//  }
}
