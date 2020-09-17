//  File name   : TopupByMoneyVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/11/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxCocoa
import RxSwift
import Eureka

@objcMembers
final class TopupByMoneyVC: FormViewController {
    /// Class's public properties.
    private var model: TopupCellModel?
    private lazy var disposeBag = DisposeBag()
    private lazy var continueButton = UIButton()
    struct Config {
        static let defaultTitle = "Nạp tiền"
        static let defaultTitleButton = "TIẾP TỤC"
    }
    
    private var credit: Double = 0
    private var hardCash: Double = 0
    
    convenience init(with item: TopupLinkConfigureProtocol?, credit: Double, hardCash: Double) {
        self.init(nibName: nil, bundle: nil)
        self.credit = credit
        self.hardCash = hardCash
        guard let item = item else {
            return
        }
        self.model = TopupCellModel.init(item: item)
    }
    
    private var headerView: TopupByMoneyHeaderView?
    
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        let t = UITableView(frame: .zero, style: .grouped)
        t.separatorColor = .clear
        t.backgroundColor = .white
        self.tableView = t
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    deinit {
        printDebug("\(#function)")
    }

}


// MARK: Class's public methods
extension TopupByMoneyVC {
}

// MARK: Class's private methods
private extension TopupByMoneyVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        continueButton >>> {
            $0.cornerRadius = 8
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            $0.setTitle(Config.defaultTitleButton, for: .normal)
            $0.setBackground(using: EurekaConfig.originNewColor, state: .normal)
            $0.setBackground(using: EurekaConfig.disabledDetailColor, state: .disabled)
        } >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(56)
                make.bottom.equalTo(-24)
            })
        }
        continueButton.isEnabled = false
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0))
        }
        self.title = Config.defaultTitle
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), landscapeImagePhone: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        //wallet-2
        let items = [TopupByMoneyItem.init(title: "Gửi", iconName: "wallet-2", description: "Số dư khả dụng\ntiền mặt", colorPrice: EurekaConfig.primaryColor, price: hardCash.currency), TopupByMoneyItem.init(title: "Nhận", iconName: "wallet-1", description: "Số dư khả dụng\ntín dụng", colorPrice: EurekaConfig.primaryColor, price: credit.currency)]
        let headerView = TopupByMoneyHeaderView(with: items)
        self.headerView = headerView
        self.tableView.tableHeaderView = headerView
        form +++ Section() { section in
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                let label = UILabel()
                label >>> view >>> {
                    $0.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
                    $0.font = EurekaConfig.titleFont
                    $0.text = "Số tiền muốn nạp"
                    $0.snp.makeConstraints {
                        $0.left.equalTo(EurekaConfig.paddingLeft)
                        $0.bottom.equalToSuperview()
                    }
                }
            }
            header.height = { 44 }
            section.header = header
        } <<< WithdrawRow("amount") {
                $0.cash = Int64(self.hardCash)
                $0.placeholder = "Số tiền khác"
                $0.update(by: self.model?.item.options)
                let min = self.model?.item.min ?? 100000
                let max = self.model?.item.max ?? 5000000
                $0.add(ruleSet: RulesTopUp.rules(minValue: min, maxValue: max))
                $0.onChange { [weak self]_ in
                    self?.validateForm()
                }
        }
    }
    
    func validateForm() {
//        let amount: Int = self.form.values().value(for: "amount", defaultValue: nil) ?? 0
//        headerView?.updateTransfer(money: amount)
        
        let errors = self.form.validate()
        self.continueButton.isEnabled = errors.count == 0
    }
    
    
    private func setupRX() {
        self.continueButton.rx.tap.bind { [unowned self] in
            self.execute(input: self.form.values(), completion: nil)
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.topUpMoneySuccess).bind { (_) in
            NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
        }.disposed(by: disposeBag)
    }
}

extension TopupByMoneyVC: FormHandlerProtocol {
    func cancelForm() {}
    
    func execute(input: [String : Any?], completion: (() -> Void)?) {
        defer { completion?() }
        guard let amount: Int = input.value(for: "amount", defaultValue: nil) else {
            return
        }
        
        defer {
            var json = [String : Any]()
            json["Amount"] = amount
            json["Channel"] = self.model?.item.topUpType?.name
            TrackingHelper.trackEvent("TopupContinue", value: json)
        }
        
        
        let topUpAction = TopUpByMoneyAction(controller: self, amount: amount, credit: self.credit, name: model?.item.name)//TopUpAction(with: amount, controller: self)
        let items = [WithdrawConfirmItem(title: "Nạp tiền", message: amount.currency, iconName: nil),
                     WithdrawConfirmItem(title: "Số tiền", message: amount.currency, iconName: nil),
                     WithdrawConfirmItem(title: "Phương thức thanh toán", message: model?.item.name ?? "", iconName: nil),
                     WithdrawConfirmItem(title: "Tổng tiền nạp", message: amount.currency, iconName: nil)]
        let confirmVC = WithdrawConfirmVC({ items }, title: "Kiểm tra", handler: topUpAction)
        
        self.navigationController?.pushViewController(confirmVC, animated: true)
        
    }
    
    
}

