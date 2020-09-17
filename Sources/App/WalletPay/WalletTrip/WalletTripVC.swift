//  File name   : WalletTripVC.swift
//
//  Author      : MacbookPro
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxCocoa
import RxSwift


enum TypeCellWalletTrip {
    case other
    case lastCell
    
    var valueContant: CGFloat {
        switch self {
        case .lastCell:
            return 0
        default:
            return 74
        }
    }
    
    static func load(index: Int, totalCell: Int) -> TypeCellWalletTrip {
        switch index {
        case totalCell - 1:
            return .lastCell
        default:
            return .other
        }
    }
}


protocol WalletTripPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func walletTripMoveBack()
    func moveAddBank()
    func selectUserBank(user: UserBankInfo)
    func moveToHistoryWallet()
    var eLoadingObser: Observable<(Bool,Double)> { get }
    var listBankUserObser: Observable<[UserBankInfo]> {get}
    var balanceObser: Observable<DriverBalance> {get}
    
    func moveToWithDraw(driverbalance: DriverBalance)
}

final class WalletTripVC: UIViewController, WalletTripPresentable, WalletTripViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: WalletTripPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    @IBOutlet weak var vShadowWithDraw: UIView!
    @IBOutlet weak var vWithDraw: UIView!
    @IBOutlet weak var btWithDraw: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var balance: DriverBalance?
    private var listBankUser: [UserBankInfo] = []
    @IBOutlet weak var lbTotalAmount: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbAmountWating: UILabel!
    
    private let disposeBag = DisposeBag()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .medium) ]
        UIApplication.setStatusBar(using: .default)
        localize()
    }
    override func viewWillDisappear(_ animated: Bool) {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .medium) ]
        UIApplication.setStatusBar(using: .lightContent)
    }

    /// Class's private properties.
}

// MARK: View's event handlers
//extension WalletTripVC {
//    override var prefersStatusBarHidden: Bool {
//        return false
//    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
//}

// MARK: Class's public methods
extension WalletTripVC {
}

// MARK: Class's private methods
private extension WalletTripVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func setupRX() {
        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        listener?.listBankUserObser.bind(onNext: weakify { (listBankUser, wSelf) in
            wSelf.listBankUser = listBankUser
            wSelf.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        listener?.balanceObser.bind(onNext: weakify { (balance, wSelf) in
            wSelf.balance = balance
            let total = balance.hardCash + balance.hardCashPending
            wSelf.lbTotalAmount.text = total.currency
            wSelf.lbAmount.text = balance.hardCash.currency
            wSelf.lbAmountWating.text = balance.hardCashPending.currency
        }).disposed(by: disposeBag)
        
        btWithDraw.rx.tap.bind { _ in
            guard let balance = self.balance else { return }
            self.listener?.moveToWithDraw(driverbalance: balance)
        }.disposed(by: disposeBag)
        
        self.listener?.listBankUserObser.bind(to: tableView.rx.items(cellIdentifier: WalletTripCell.identifier, cellType: WalletTripCell.self)) {[weak self] (row, element, cell) in
            guard let wSelf = self else { return }
            let type = TypeCellWalletTrip.load(index: row, totalCell: wSelf.listBankUser.count)
            cell.vLineLeading.constant = type.valueContant
            cell.updateUI(model: element)
        }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            wSelf.listener?.selectUserBank(user: wSelf.listBankUser[indexPath.row])
        }.disposed(by: disposeBag)
    }
    private func visualize() {
        // todo: Visualize view's here.
       let buttonLeft = visualizeButtonLeft(imgLeft: "ic_header_back_grey_new")
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.walletTripMoveBack()
        }).disposed(by: disposeBag)
        
        let buttonRight = visualizeButtonRight(imgRight: "ic_history_wallet")
        buttonRight.rx.tap.bind { wSelf in
            self.listener?.moveToHistoryWallet()
        }.disposed(by: disposeBag)
        
        
        visualizeWhiteNavigationBar(titleStr: "Doanh thu chuyến đi")
        
        view.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.9686274529, blue: 0.9686274529, alpha: 1)
        
        self.vShadowWithDraw.backgroundColor = .clear
        self.vShadowWithDraw.layer.shadowOpacity = 0.7
        self.vShadowWithDraw.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.vShadowWithDraw.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.24)
        self.vShadowWithDraw.layer.shadowRadius = 4.0;
        self.vWithDraw.backgroundColor = .white
        
        self.tableView.delegate = self
        self.tableView.register(WalletTripCell.nib, forCellReuseIdentifier: WalletTripCell.identifier)

    }
}
extension WalletTripVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        
        v.backgroundColor = .white
        
        let imgBG: UIImageView = UIImageView(image: UIImage(named: "ic_bgAdd_bank"))
        
        v.addSubview(imgBG)
        imgBG.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(16)
        }
        
        let lbNewAccount: UILabel = UILabel(frame: .zero)
        lbNewAccount.text = "Thêm tài khoản ngân hàng"
        lbNewAccount.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        lbNewAccount.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        v.addSubview(lbNewAccount)
        lbNewAccount.snp.makeConstraints { (make) in
            make.centerY.equalTo(imgBG)
            make.centerX.equalTo(imgBG)
        }
        
        let imgAdd: UIImageView = UIImageView(image: UIImage(named: "ic_add_bank"))
        
        v.addSubview(imgAdd)
        imgAdd.snp.makeConstraints { (make) in
            make.centerY.equalTo(lbNewAccount)
            make.width.height.equalTo(16)
            make.right.equalTo(lbNewAccount.snp.left).inset(-8)
        }
        
        let btAddBank: UIButton = UIButton(type: .system)
        btAddBank.backgroundColor = .clear
        
        v.addSubview(btAddBank)
        btAddBank.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        btAddBank.rx.tap.bind { _ in
            self.listener?.moveAddBank()
        }.disposed(by: disposeBag)
        
        return v
    }
}
//extension WalletTripVC: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.listBankUser.count
//    }
//
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: WalletTripCell.identifier) as! WalletTripCell
////
////        let type = TypeCellWalletTrip.load(index: indexPath, totalCell: self.listBankUser.count)
////        cell.vLineLeading.constant = type.valueContant
////
////        cell.updateUI(model: self.listBankUser[indexPath.row])
////
////        return cell
////    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.listener?.selectUserBank(user: self.listBankUser[indexPath.row])
//    }
//}
