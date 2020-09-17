//  File name   : WTWithDrawSuccessVC.swift
//
//  Author      : admin
//  Created date: 5/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxCocoa
import RxSwift

protocol WTWithDrawSuccessPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func moveBackSourceWallet()
    var topUpInfoObser: Observable<PointTransactionInfo> { get }
    var bankInfoObser: Observable<BankTransactionInfo> {get}
}

typealias BankTransactionInfo = (user: UserBankInfo?, balance: DriverBalance?)
typealias PointTransactionInfo = (topup: TopupCellModel?, point: Int?)

final class WTWithDrawSuccessVC: UIViewController, WTWithDrawSuccessPresentable, WTWithDrawSuccessViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: WTWithDrawSuccessPresentableListener?

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationItem.hidesBackButton = true
    }

    /// Class's private properties.
    private let disposeBag = DisposeBag()
    private var items: [WithdrawConfirmItem] = []
}

// MARK: View's event handlers
extension WTWithDrawSuccessVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension WTWithDrawSuccessVC {
}

// MARK: Class's private methods
private extension WTWithDrawSuccessVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        
        let closeBtn = UIButton.create {
            $0.setBackgroundImage(#imageLiteral(resourceName: "bg_button01"), for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle("Đóng", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.height.equalTo(54)
                    make.bottom.equalTo(-16)
                })
        }
        closeBtn.rx.tap.bind { [weak self] in
            self?.listener?.moveBackSourceWallet()
        }
        .disposed(by: disposeBag)
    }
    
    private func setupRX() {
        listener?.topUpInfoObser.bind(onNext: weakify { (topupInfo, wSelf) in
            if let hasPoint = topupInfo.point, let hasItem =  topupInfo.topup {
                let titles = ["Mua điểm thành công", "Số điểm", "Kênh nạp tiền", "Số điểm cuối cùng"]
                let str = "+" + hasPoint.point
                wSelf.setupView(titles, mss: [str, hasPoint.point, hasItem.item.name ?? "", hasPoint.point], colorPrice: EurekaConfig.primaryColor)
            }
        }).disposed(by: disposeBag)
        
        listener?.bankInfoObser.bind(onNext: weakify { (bankinfo, wSelf) in
            if let user = bankinfo.user, let balance = bankinfo.balance {
                let textAmount = "-" + "\(user.amountNeedWithDraw?.currency ?? "")"
                let bankName = user.bankInfo?.bankShortName ?? ""
                let amount = (Int(balance.hardCash) - (user.amountNeedWithDraw ?? 0)).currency
                let arMss = [textAmount, textAmount , bankName, amount]
                let titles = ["Rút tiền thành công", "Số tiền rút", "Ngân hàng", "Doanh thu còn lại"]
                wSelf.setupView(titles, mss: arMss, colorPrice: #colorLiteral(red: 1, green: 0.1411764706, blue: 0.1411764706, alpha: 1))
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupView(_ titles: [String], mss: [String], colorPrice: UIColor) {
        for (t,m) in zip(titles,mss) {
            let item = WithdrawConfirmItem(title: t, message: m, iconName: "ic_confirm_check")
            items.append(item)
        }
        
        title = items[0].title
        
        WTWithdrawContentView(with: items, colorPrice: colorPrice, parentView: view)
    }
}
