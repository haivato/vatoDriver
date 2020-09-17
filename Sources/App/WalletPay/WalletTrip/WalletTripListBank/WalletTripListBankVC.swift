//  File name   : WalletTripListBankVC.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa

protocol WalletTripListBankPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBackAddBank()
    func selectBank(itemBank: BankInfoServer)
    var listBankObser: Observable<[BankInfoServer]> { get }
}

final class WalletTripListBankVC: UIViewController, WalletTripListBankPresentable, WalletTripListBankViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: WalletTripListBankPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    private var listBank: [BankInfoServer] = []
    private let disposeBag = DisposeBag()
    private let maxCellDisPlay = 5
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        setupRX()
    }
    
    /// Class's private properties.
}

// MARK: View's event handlers
extension WalletTripListBankVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension WalletTripListBankVC {
}

// MARK: Class's private methods
private extension WalletTripListBankVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = visualizeButtonLeft()
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            //            wSelf.listener?.walletTripMoveBack()
        }).disposed(by: disposeBag)
        title = "Danh sách ngân hàng"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WTListBankCell.nib, forCellReuseIdentifier: WTListBankCell.identifier)
        let v: HeaderCornerView = HeaderCornerView(with: 7)
        v.containerColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.tableView.insertSubview(v, at: 0)
        v >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        
        
        
    }
    
    private func setupRX() {
        listener?.listBankObser.bind(onNext: weakify { (listBank, wSelf) in
            wSelf.listBank = listBank
            wSelf.tableView.isScrollEnabled = (listBank.count <= wSelf.maxCellDisPlay) ? false : true
            wSelf.tableView.reloadData()
            
            UIView.animate(withDuration: 0, animations: {
                self.tableView.layoutIfNeeded()
            }) { (complete) in
                var heightOfTableView: CGFloat = 0.0
                let cells = self.tableView.visibleCells
                let count = min(cells.count, self.maxCellDisPlay)
                for (index, element) in cells.enumerated() {
                    if index < count {
                        heightOfTableView += element.frame.height
                    }
                }
                self.heightTableView.constant = heightOfTableView + 86
                self.view.isHidden = false
                self.view.layoutIfNeeded()
            }
        }).disposed(by: disposeBag)
    }
}
extension WalletTripListBankVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 26
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        
        let lbTitle: UILabel = UILabel(frame: .zero)
        lbTitle.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lbTitle.text = Text.listBank.localizedText
        lbTitle.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        
        v.addSubview(lbTitle)
        lbTitle.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        
        let btClose: UIButton = UIButton(type: .custom)
        btClose.setImage(UIImage(named: "ic_header_close_grey"), for: .normal)
        
        v.addSubview(btClose)
        btClose.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(44)
        }
        
        btClose.rx.tap.bind { _ in
            self.listener?.moveBackAddBank()
        }.disposed(by: disposeBag)
        
        
        return v
    }
    
}
extension WalletTripListBankVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listBank.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WTListBankCell.identifier) as! WTListBankCell
        cell.updateUI(model: self.listBank[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listener?.selectBank(itemBank: self.listBank[indexPath.row] )
    }
}
