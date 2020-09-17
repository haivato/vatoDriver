//
//  WTViewBank.swift
//  FC
//
//  Created by MacbookPro on 5/25/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class WTViewBank: UIView {

    var didSelect: ((_ indexPath: IndexPath) -> Void)?
    @IBOutlet weak var tableView: UITableView!
    var listBankUser: [UserBankInfo] = []
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(WalletTripCell.nib, forCellReuseIdentifier: WalletTripCell.identifier)
        
        setupRX()
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    private func setupRX() {
        self.tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            wSelf.didSelect?(indexPath)
        }.disposed(by: disposeBag)
    }
}

extension WTViewBank: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
extension WTViewBank: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listBankUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WalletTripCell.identifier) as! WalletTripCell
        
        let typeCell = TypeCellWalletTrip.load(index: indexPath.row, totalCell: self.listBankUser.count)
        cell.vLineLeading.constant = typeCell.valueContant
        
        cell.updateUI(model: self.listBankUser[indexPath.row])
        
        return cell
    }
}
