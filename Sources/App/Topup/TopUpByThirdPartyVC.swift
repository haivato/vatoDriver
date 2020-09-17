//  File name   : TopUpByThirdPartyVC.swift
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

final class TopUpByThirdPartyVC: FormViewController {
    /// Class's public properties.
    @IBOutlet weak var continueButton: UIButton!
    private var model : TopupCellModel?
    private lazy var disposeBag: DisposeBag = DisposeBag()
    
    convenience init(model: TopupCellModel?) {
        self.init(nibName: "TopUpByThirdPartyVC", bundle: nil)
        self.model = model
    }
    
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



// MARK: Class's private methods
private extension TopUpByThirdPartyVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        let background = #imageLiteral(resourceName: "bg_button01").withRenderingMode(.alwaysTemplate)
        continueButton.setBackgroundImage(background, for: .disabled)
        continueButton.isEnabled = false
        continueButton.tintColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
        self.continueButton.isEnabled = false
        // todo: Visualize view's here.
        self.title = model?.item.name
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), landscapeImagePhone: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        let section = Section() { section in
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                let label = UILabel()
                label >>> view >>> {
                    $0.textColor = EurekaConfig.titleColor
                    $0.font = EurekaConfig.titleFont
                    $0.text = "tài khoản điện tử"
                    $0.snp.makeConstraints {
                        $0.left.equalTo(EurekaConfig.paddingLeft)
                        $0.right.equalToSuperview()
                        $0.bottom.equalToSuperview()
                    }
                }
            }
            header.height = { 36 }
            section.header = header
        }
        form +++ section
        
        section <<< TopupRow("1") {
            $0.value = self.model
            $0.hide(arrow: true)
        }
        
        form +++ Section() { section in
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                let label = UILabel()
                label >>> view >>> {
                    $0.textColor = EurekaConfig.titleColor
                    $0.font = EurekaConfig.titleFont
                    $0.text = "Số tiền muốn nạp"
                    $0.snp.makeConstraints {
                        $0.edges.equalTo(UIEdgeInsets(top: 0.0, left: EurekaConfig.paddingLeft, bottom: 0.0, right: 0.0))
                    }
                }
            }
            section.header = header
            
            var footer = HeaderFooterView<UIView>(.callback { UIView.create({
                $0.backgroundColor = .white
            }) })
            footer.onSetupView = { (view, _) in
                let label = UILabel()
                label.backgroundColor = .white
                label >>> view >>> {
                    $0.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
                    $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                    $0.text = "Tối thiểu từ \(100000.currency) và là bội số của \(10000.currency)"
                    $0.snp.makeConstraints {
                        $0.top.equalTo(15)
                        $0.left.equalTo(EurekaConfig.paddingLeft)
                    }
                }
            }
            footer.height = { 59 }
            section.footer = footer
            
            }
            <<< WithdrawRow("amount") {
                $0.cash = 2000000
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
    
    private func validateForm() {
        
        let errors = self.form.validate()
        self.continueButton.isEnabled = errors.count == 0
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.

        // Setup view model
        self.continueButton.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.execute(form: wSelf.form, prefixAction: nil, suffixAction: nil)
        }.disposed(by: disposeBag)
    }
}

extension TopUpByThirdPartyVC: FormHandlerProtocol {
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

        guard let name = self.model?.item.topUpType?.name else {
            return
        }
        
        let topUpAction = TopUpAction(with: name, amount: amount, controller: self, topUpItem: self.model)
        let items = [WithdrawConfirmItem(title: "Nạp tiền", message: amount.currency, iconName: nil),
                     WithdrawConfirmItem(title: "Số tiền", message: amount.currency, iconName: nil),
                     WithdrawConfirmItem(title: "Phương thức thanh toán", message: model?.item.name ?? "", iconName: nil),
                     WithdrawConfirmItem(title: "Tổng tiền nạp", message: amount.currency, iconName: nil)]
        let confirmVC = WithdrawConfirmVC({ items }, title: "Kiểm tra", handler: topUpAction)
        
        self.navigationController?.pushViewController(confirmVC, animated: true)
        
    }
    
    
}
