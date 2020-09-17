//  File name   : TopUpChooseVC.swift
//
//  Author      : Dung Vu
//  Created date: 11/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxCocoa
import RxSwift
import Eureka

protocol DummyMethodProtocol {}
class DummyTopupMethod: NSObject, TopupLinkConfigureProtocol, DummyMethodProtocol {
    func clone() -> TopupLinkConfigureProtocol {
        let clone = DummyTopupMethod()
        clone.type = self.type
        clone.name = self.name
        clone.url = self.url
        clone.auth = self.auth
        clone.active = self.active
        clone.iconURL = self.iconURL
        clone.min = self.min
        clone.max = self.max
        clone.options = self.options
        return clone
    }
    
    var type: Int = -1
    var name: String?
    var url: String?
    var auth: Bool = false
    var active: Bool = false
    var iconURL: String?
    var min: Int = 0
    var max: Int = 0
    var options: [Double]?
}

protocol TopUpHandlerResultProtocol: AnyObject {
    func topHandlerResult()
}

@objcMembers
final class TopUpChooseVC: FormViewController {
    struct TopUpConfig {
        static let title: String = "Kênh nạp tiền"
    }
    
    /// Class's public properties.
    private var items: [TopupCellModel] = []
    private lazy var disposeBag: DisposeBag = DisposeBag()

    private lazy var bankTransferWrapper = BankTransferWrapper(with: self)

    convenience init(with items: [TopupLinkConfigureProtocol]) {
        self.init(style: .grouped)
        var currentItems = items.filter({ $0.active })

        // Check if need dummy
        let needDummy = currentItems.map { $0.name?.uppercased() }.first(where: { $0?.contains("napas") == true }) == nil
        if needDummy {
            // add dummy
            let master = DummyTopupMethod()
            master.name = "Master (Đang cập nhật)"
            master.iconURL = "ic_mastercard"

            let visa = DummyTopupMethod()
            visa.name = "Visa (Đang cập nhật)"
            visa.iconURL = "ic_visa"

            let atm = DummyTopupMethod()
            atm.name = "ATM (Đang cập nhật)"
            atm.iconURL = "ic_atm"

            currentItems.append(master)
            currentItems.append(visa)
            currentItems.append(atm)
        }

        self.items = currentItems
            .map({ TopupCellModel.init(item: $0) })
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    private func visualize() {
        self.tableView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.9176470588, blue: 0.9450980392, alpha: 1)
        self.title = TopUpConfig.title
        self.tableView.separatorStyle = .none
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), landscapeImagePhone: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
//        let section = Section()
//        self.form +++ section
//
//        self.items.enumerated().forEach { (idx, model) in
//            section <<< TopupRow("row at \(idx)", {
//                $0.value = model
//                $0.onCellSelection { [weak self](cell, row) in
//                    self?.handler(select: row.value)
//                }
//            })
//        }
    }
    
    private func handler(select: TopupCellModel?) {
        guard let model = select, let type = model.item.topUpType else {
            return
        }
        defer {
            TrackingHelper.trackEvent("ToupChannel", value: ["Channel": type.name])
        }

        switch type {
        case .napas:
            let webVC = FCNewWebViewController()
            webVC.modalPresentationStyle = .fullScreen
            self.navigationController?.present(webVC, animated: true, completion: {
                webVC.loadWebview(withConfigure: model.item)
            })
        case .zaloPay:
            let topupThirdPartyVC = TopUpByThirdPartyVC(model: model)
            topupThirdPartyVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(topupThirdPartyVC, animated: true)
        case .momoPay:
            let topupThirdPartyVC = TopUpByThirdPartyVC(model: model)
            topupThirdPartyVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(topupThirdPartyVC, animated: true)

        case .bankTransfer:
            bankTransferWrapper.present()
        default:
            return
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }

    private func setupRX() {
        let node = FireBaseTable.master >>> FireBaseTable.appConfigure >>> FireBaseTable.custom(identify: "bank_transfer_config")
        firebaseDatabase.find(by: node, type: .value, using: { ref in
            ref.keepSynced(true)

            let query = ref.queryOrdered(byChild: "active").queryEqual(toValue: true)
            return query
        })
        .timeout(10.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
        .take(1)
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(onNext: { [weak self] (snapshot) in
            guard let wSelf = self else {
                return
            }

            let children = snapshot.children.compactMap { $0 as? DataSnapshot }.compactMap { try? FirebaseModel.BankTransferConfig.create(from: $0) }
            if children.count <= 0 {
                wSelf.items = wSelf.items.filter { $0.item.topUpType != .bankTransfer }
            }

            let section = Section()
            wSelf.form +++ section

            wSelf.items.enumerated().forEach { (idx, model) in
                section <<< TopupRow("row at \(idx)", {
                    $0.value = model
                    $0.onCellSelection { [weak self](cell, row) in
                        self?.handler(select: row.value)
                    }
                })
            }
        })
        .disposed(by: disposeBag)
    }

    /// Class's private properties.
    private lazy var firebaseDatabase = Database.database().reference()
}



