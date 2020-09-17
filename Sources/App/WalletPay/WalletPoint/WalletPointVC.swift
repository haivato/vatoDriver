//  File name   : WalletPointVC.swift
//
//  Author      : admin
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCoreRX
import FwiCore
import RxSwift
import RxCocoa

protocol WalletPointPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func moveBack()
    func gotoBuyPoint(_ list: [Any], balance: DriverBalance?, index: IndexPath)
    func gotoLinkCard()
    func moveToListHistoryCredit()
    var listTopUpMethodObser: Observable<[TopUpMethod]> {get}
    var listCardObser: Observable<[Card]> {get}
    var balanceObser: Observable<DriverBalance> {get}
    var eLoadingObser: Observable<(Bool,Double)> { get }
    var listNapasObs: Observable<[PaymentCardType]> { get }
}

final class WalletPointVC: UIViewController, WalletPointPresentable, WalletPointViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: WalletPointPresentableListener?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var availableAmountLbl: UILabel!
    @IBOutlet weak var pendingAmountLbl: UILabel!
    @IBOutlet weak var btTopUp: UIButton!
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .medium) ]
        UIApplication.setStatusBar(using: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .medium) ]
        UIApplication.setStatusBar(using: .lightContent)
    }
    
    /// Class's private properties.
    private let disposeBag = DisposeBag()
    private var newList: [Any] = []
    private var balance: DriverBalance?
    
    private func reloadView(_ balance: DriverBalance) {
        totalAmountLbl.text = (balance.credit + balance.creditPending).point
        availableAmountLbl.text = balance.credit.point
        pendingAmountLbl.text = balance.creditPending.point
    }
}

// MARK: View's event handlers
extension WalletPointVC {
}

// MARK: Class's public methods
extension WalletPointVC {
}

// MARK: Class's private methods
private extension WalletPointVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = visualizeButtonLeft(imgLeft: "ic_food_search_back")
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
        
        let buttonRight = visualizeButtonRight(imgRight: "ic_history")
        buttonRight.rx.tap.bind(onNext: weakify { wSelf in
            self.listener?.moveToListHistoryCredit()
        }).disposed(by: disposeBag)
                
        visualizeWhiteNavigationBar(titleStr: "Điểm nhận chuyến")
        
        view.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.9686274529, blue: 0.9686274529, alpha: 1)
        
        setUpTableView()
        
        btTopUp.backgroundColor = .white
        btTopUp.setTitle("Liên kết bằng thẻ Napas", for: .normal)
        btTopUp.setImage(UIImage(named: ""), for: .normal)
        btTopUp.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
        btTopUp.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btTopUp.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        btTopUp.semanticContentAttribute = .forceRightToLeft
        btTopUp.adjustsImageWhenHighlighted = false
        
        btTopUp.layer.cornerRadius = 24
        btTopUp.layer.borderColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        btTopUp.layer.borderWidth = 1.0
        
        btTopUp.rx.tap.bind(onNext: weakify { wSelf in
            self.listener?.gotoLinkCard()
        }).disposed(by: disposeBag)
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.register(EWalletBuyingTableViewCell.nib, forCellReuseIdentifier: EWalletBuyingTableViewCell.identifier)
        tableView.rowHeight = 72
    }
    
    private func setupRX() {
        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
                
        if let listener = listener {
            Observable.combineLatest(listener.listTopUpMethodObser, listener.listCardObser, listener.balanceObser).bind {[weak self] (listTopUp, listCard, balance) in
                guard let wself = self else { return }
                wself.reloadView(balance)
                
                let myMethod = TopUpMethod(type: 0, name: "Doanh thu chuyến đi", url: nil, auth: true, active: true, iconURL: "", min: 50000, max: 5000000, options: [50000,200000,1000000])

                var list: [Any] = []
                list.append(myMethod)
                list.append(contentsOf: listTopUp.dropLast())
                list.append(contentsOf: listCard)
                wself.newList = list
                wself.balance = balance

                Observable.just(list).bind(to: wself.tableView.rx.items(cellIdentifier: EWalletBuyingTableViewCell.identifier, cellType: EWalletBuyingTableViewCell.self)) { (row, element, cell) in
                    cell.displayCell(element, balance: balance.hardCash)
                }.disposed(by: wself.disposeBag)
            }
            .disposed(by: disposeBag)
        }
        
        listener?.listNapasObs.bind(onNext: weakify { (listNapas, wSelf) in
            wSelf.btTopUp.isHidden = (listNapas.count > 0) ? false : true
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.bind { (idx) in
            self.listener?.gotoBuyPoint(self.newList, balance: self.balance, index: idx)
        }.disposed(by: disposeBag)
    }
}

extension WalletPointVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        v.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let title: UILabel = UILabel()
        title.text = "Mua điểm từ:"
        title.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        title.textColor =  #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        
        v.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        return v
    }
}

