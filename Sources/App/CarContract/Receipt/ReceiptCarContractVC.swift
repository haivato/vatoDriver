//  File name   : ReceiptCarContractVC.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxCocoa
import RxSwift
import FwiCore
import Atributika

protocol ReceiptCarContractPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var itemObs: Observable<OrderContract> { get }
    func moveBack()
    func routeToHome()
}

final class ReceiptCarContractVC: UIViewController, ReceiptCarContractPresentable, ReceiptCarContractViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ReceiptCarContractPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    private var viewDetailPrice: DetailPriceView = DetailPriceView(frame: .zero)
    private var item: OrderContract?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    private let disposeBag = DisposeBag()
    @IBOutlet weak var btComplete: UIButton!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbAmountMoney: UILabel!
    
    /// Class's private properties.
}

// MARK: View's event handlers
extension ReceiptCarContractVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ReceiptCarContractVC {
}

// MARK: Class's private methods
private extension ReceiptCarContractVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind { _ in
            self.listener?.moveBack()
        }.disposed(by: disposeBag)
        title = "Hoá đơn hợp đồng"
        buttonLeft.isHidden = true
        
        let s = viewDetailPrice.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        viewDetailPrice >>> self.view >>> {
            $0.frame.size = s
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(16)
                make.top.equalTo(self.lbContent.snp.bottom).inset(20)
            }
        }
    }
    private func setupRX() {
        self.listener?.itemObs.bind(onNext: weakify({ (item, wSelf) in
            wSelf.item = item
            let total = item.cost?.total ?? 0
            let deposit = item.cost?.deposit ?? 0
            wSelf.lbAmountMoney.text = (total - deposit).currency
            wSelf.setupDetailPrice(total: total, deposit: deposit)
        })).disposed(by: disposeBag)
        
        self.btComplete.rx.tap.bind { _ in
            self.listener?.routeToHome()
        }.disposed(by: disposeBag)
    }
    private func setupDetailPrice(total: Double, deposit: Double) {
        var styles = [PriceInfoDisplayStyle]()
        let allTitle = Atributika.Style.font(.systemFont(ofSize: 15, weight: .regular)).foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1))
        let allPrice = Atributika.Style.font(.systemFont(ofSize: 15, weight: .regular)).foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
        let lastPrice = Atributika.Style.font(.systemFont(ofSize: 20, weight: .medium)).foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
        //        let discountPrice = Atributika.Style.font(.systemFont(ofSize: 15, weight: .medium)).foregroundColor(#colorLiteral(red: 0.9333333333, green: 0.3215686275, blue: 0.1333333333, alpha: 1))
        
        let seats = FwiLocale.localized("Giá cước").styleAll(allTitle).attributedString
        let textPriceFee = total.currency.styleAll(allPrice).attributedString
        
        let styleSeats = PriceInfoDisplayStyle(attributeTitle: seats,
                                               attributePrice: textPriceFee,
                                               showLine: false,
                                               edge: .zero)
        styles.append(styleSeats)
        
        
        let lbMoney = FwiLocale.localized("Đã cọc").styleAll(allTitle).attributedString
        let textMoney = deposit.currency.styleAll(allPrice).attributedString
        
        let styleMoney = PriceInfoDisplayStyle(attributeTitle: lbMoney,
                                               attributePrice: textMoney,
                                               showLine: false,
                                               edge: .zero)
        styles.append(styleMoney)
        
        
        
        //               let totalLastPrice = (finalPrice >= 0) ? (finalPrice) : totalPrice
        let lbTotalPrice = FwiLocale.localized("Còn lại").styleAll(allTitle).attributedString
        let amount = max(total - deposit, 0)
        let textTotalPrice = amount.currency.styleAll(lastPrice).attributedString
        
        let styleTotalPrice = PriceInfoDisplayStyle(attributeTitle: lbTotalPrice,
                                                    attributePrice: textTotalPrice,
                                                    showLine: true,
                                                    edge: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        styles.append(styleTotalPrice)
        
        
        viewDetailPrice.setupDisplay(item: styles)
        self.view.layoutIfNeeded()
    }
}
