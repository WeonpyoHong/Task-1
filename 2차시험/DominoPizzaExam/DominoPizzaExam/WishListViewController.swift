//
//  WishListViewController.swift
//  DominoPizzaExam
//
//  Created by Kira on 24/04/2019.
//  Copyright © 2019 Kira. All rights reserved.
//

import UIKit

final class WishListViewController: UIViewController {
  let tableView = UITableView()
  weak var menu: PizzaList?
  var orders: [MenuInfo]? = []
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Wish List"
    
    tableView.rowHeight = 100
    tableView.dataSource = self
    view.addSubview(tableView)
    
    // 탭바 컨트롤러 델리게이트 사용
    tabBarController?.delegate = self
    
    naviSetting()
    autoLayouts()
    loadOrders()
  }

  // 네비게이션 바 셋팅
  func naviSetting() {
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "목록 지우기", style: .done, target: self, action: #selector(deleteList(_:)))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "주문", style: .done, target: self, action: #selector(order(_:)))
  }
  
  func autoLayouts() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
  }
  
  // 주문 수량이 1 이상인 메뉴 검색 및 추출
  func loadOrders() {
    orders = menu?.menus.map { $0.value.filter { $0.getQauntity() > 0} } . flatMap {$0}
  }
  
  // 주문 list message 생성
  func getOrderList() -> String {
    var listOrder = ""
    var totalPrice = 0
    orders?.forEach {
      listOrder += "\($0.menuName) - \($0.getQauntity())개 \n"
      totalPrice += $0.menuPrice * $0.getQauntity()
    }
    listOrder += "금액결제 :\(totalPrice)"
    return listOrder
  }
  
  func orderReset() {
    orders?.forEach { $0.setZeroOrderQuantity() } // 주문 수량 초기화
    orders?.removeAll()                           // 주문 리스트 초기화
    tableView.reloadData()
  }
  
  @objc func deleteList(_ sender: UIBarButtonItem) {
    orderReset()
  }
  
  @objc func order(_ sender: UIBarButtonItem) {
    let alertController = UIAlertController(title: "결제내역", message: getOrderList(), preferredStyle: .alert)
    let returnAlertAction = UIAlertAction(title: "되돌아가기", style: .cancel)
    let paymentAlertAction = UIAlertAction(title: "결제하기", style: .default) { action in self.orderReset() }
    
    alertController.addAction(returnAlertAction)
    alertController.addAction(paymentAlertAction)
    
    present(alertController, animated: true)
  }
}

extension WishListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
    cell.textLabel?.text = "\(orders?[indexPath.row].menuName ?? "")"
    cell.detailTextLabel?.text = "주문수량 : \(orders?[indexPath.row].getQauntity() ?? 0)"
    cell.imageView?.image = UIImage(named: orders?[indexPath.row].menuName ?? "")
    cell.accessoryType = .none
    return cell
  }
}

/***********************************************************
 수정 정보 초기화를 위한 탭바 컨트롤러 델리게이트
 **********************************************************/
extension WishListViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    switch viewController.children.last {
    case is WishListViewController: // wish list 선택시 셋팅
      loadOrders()
      tableView.reloadData()
    case let view as DetailViewController: // detailview 선택시 셋팅
      view.showBuyLabel()
    default:
      break
    }
  }
}
