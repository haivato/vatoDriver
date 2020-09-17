//  File name   : TOOrderVC.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol TOOrderPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func TOOrderMoveBack()
    func routeToLocation(pickUpStationId: Int?, firestore_listener_path: String?)
    var values: Observable<TOOrderData> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
}

enum TOOrderSectionType: Int, CaseIterable {
    case joined = 0
    case requestOrder
    case listLocation
    
    var name: String {
        switch self {
        case .joined:
            return "Điểm tiếp thị đã tham gia"
        case .requestOrder:
            return "Đang chờ phản hồi"
        case .listLocation:
            return "Danh sách điểm tiếp thị"
        }
    }
}

final class TOOrderVC: UIViewController, TOOrderPresentable, TOOrderViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TOOrderPresentableListener?
    private lazy var disposeBag = DisposeBag()
    @VariableReplay(wrappedValue: [:]) private var source: TOOrderData
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        return t
    }()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension TOOrderVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension TOOrderVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TOOrderTVC.identifier) as? TOOrderTVC, let type = TOOrderSectionType(rawValue: indexPath.section)  else {
            fatalError("Please Implement")
        }
        let item = source[type]?[safe: indexPath.item]
        cell.setupDisplay(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = TOOrderSectionType(rawValue: section)  else {
            return 0
        }
        return source[type]?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TOOrderSectionType.allCases.count
    }
}

extension TOOrderVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let type = TOOrderSectionType(rawValue: section) else { return nil }
        let contentView = UIView(frame: .zero)
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        
        let lblDescription = UILabel(frame: .zero)
        lblDescription >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.text = type.name
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.bottom.equalTo(-8)
            }
        }
        
        return contentView
    }
    
    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let type = TOOrderSectionType(rawValue: section)  else {
            return 0.1
        }
        let count = source[type]?.count ?? 0
        return count == 0 ? 0.1 : 40
    }

    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

}


// MARK: Class's public methods
extension TOOrderVC {
}

// MARK: Class's private methods
private extension TOOrderVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.TOOrderMoveBack()
        }).disposed(by: disposeBag)
        title = "Xếp tài Taxi"
        
        let lblVersion = LabelVersion(frame: .zero)
        lblVersion >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(15)
                make.bottom.equalTo(-20)
            }
        }
        
        tableView >>> view >>> {
            $0.rowHeight = 74
            $0.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(lblVersion.snp.top)
            }
        }
        
        tableView.register(TOOrderTVC.self, forCellReuseIdentifier: TOOrderTVC.identifier)
    }
    
    func setupRX() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.setDataSource(self).disposed(by: disposeBag)
        listener?.values.bind(to: $source).disposed(by: disposeBag)
        
        $source.bind(onNext: weakify({ (list, wSelf) in
            wSelf.tableView.reloadData()
        })).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.bind(onNext: weakify({ (index, wSelf) in
            guard let type = TOOrderSectionType(rawValue: index.section)  else { return }
            wSelf.listener?
                .routeToLocation(pickUpStationId: wSelf.source[type]?[index.row].pickupStationId,
                                            firestore_listener_path: wSelf.source[type]?[index.row].firestore_listener_path)
        })).disposed(by: disposeBag)
        
        listener?.eLoadingObser.bind(onNext: { (value) in
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
    }
}
