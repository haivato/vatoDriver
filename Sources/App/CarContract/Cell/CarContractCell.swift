//
//  CarContractCell.swift
//  FC
//
//  Created by Phan Hai on 28/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CarContractCell: UITableViewCell, UpdateDisplayProtocol {

    
    func setupDisplay(item: OrderContract?) {
        guard let item = item else {
            return
        }
        self.viewCarContract.bindData(item: item)
    }
    var call: (() -> Void)?
    var btChat: (() -> Void)?
    var viewCarContract: CarContractView = CarContractView.loadXib()
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addSubview(viewCarContract)
        viewCarContract.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview().inset(10)
        }
        self.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        setupRX()
    }
    private func setupRX() {
        viewCarContract.btCancel.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else {
                return
            }
            switch wSelf.viewCarContract.type {
            case .CREATED, .DRIVER_STARTED, .DRIVER_ACCEPTED:
                wSelf.call?()
            default:
                break
            }
        }.disposed(by: disposeBag)
        
        viewCarContract.btChat.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else {
                return
            }
            switch wSelf.viewCarContract.type {
            case .CREATED,.DRIVER_STARTED, .DRIVER_ACCEPTED:
                wSelf.btChat?()
            default:
                break
            }
        }.disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
