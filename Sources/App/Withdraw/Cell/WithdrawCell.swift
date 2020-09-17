//  File name   : WithdrawCell.swift
//
//  Author      : Vato
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import Eureka

class WithdrawCellModel: WithdrawPriceDisplayProtocol, WithdrawCanSelectProtocol {
    var isPrice: Bool
    var price: Double
    var canSelect: Bool

    init(price: Double, canSelect: Bool, isPrice: Bool = true) {
        self.price = price
        self.canSelect = canSelect
        self.isPrice = isPrice
    }
}

enum WithdrawAnalytic {
    case topup
    case widthraw
}


final class WithdrawCell: MasterFieldCell<Int>, CellType {
    // MARK: Class's public methods
    var analyticType = WithdrawAnalytic.topup
    override func setup() {
        super.setup()
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
            
        // General setup
        height = { return 120.0 }
        backgroundColor = .clear
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil

        withdrawByPriceView >>> contentView >>> { $0.snp.makeConstraints {
            $0.leading.equalTo(borderImageView.snp.leading)
            $0.trailing.equalTo(borderImageView.snp.trailing)
            $0.bottom.equalTo(titleLabel.snp.top).offset(-5.0)
            $0.height.equalTo(48.0)
        }}

        // Check cash
        guard let cash = (row as? WithdrawRow)?.cash else {
            return
        }
        let validateCash = Double(cash)

        items.forEach { $0.canSelect = $0.price <= validateCash }
        withdrawByPriceView.update(by: items)

        _ = withdrawByPriceView.select
            .map { [weak self] (indexPath) -> WithdrawCellModel? in
                guard
                    let index = indexPath?.item,
                    0 <= index && index <= self?.items.count ?? 0
                else {
                    return nil
                }
                return self?.items[index]
            }
            .filterNil()
            .takeUntil(self.rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] (item) in
                guard let wSelf = self else {
                    return
                }
                
                let v = Int(item.price)
                defer {
                    wSelf.trackSelect(by: v)
                }
                wSelf.row.value = v
                wSelf.row.updateCell()
            })
    }

    override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        withdrawByPriceView.currentIndex = nil
    }

    override func update() {
        super.update()
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil
    }
    
    func setPriceViewSelected(indexPath: IndexPath) {
        withdrawByPriceView.currentIndex = indexPath
    }

    /// Class's private properties.
    private var items = [
        WithdrawCellModel(price: 200000, canSelect: false),
        WithdrawCellModel(price: 500000, canSelect: false),
        WithdrawCellModel(price: 1000000, canSelect: false)
    ]
    private lazy var withdrawByPriceView = WithdrawByPriceControl(by: items, currentSelect: nil)
    
    func update(by items: [Double]?, isPrice: Bool) {
//    func update(by items: [Double]?) {
        let temp = items ?? []
        let n = temp.count > 0 ? temp : [200000, 500000, 1000000]
        let validateCash = Double((row as? WithdrawRow)?.cash ?? 0)
        let result = n.map { WithdrawCellModel(price: $0, canSelect: $0 <= validateCash, isPrice: isPrice )}
//        let result = n.map { WithdrawCellModel(price: $0, canSelect: $0 <= validateCash )}
        self.items = result
        withdrawByPriceView.update(by: result)
    }
    
    func setAnalytic(_ type: WithdrawAnalytic) {
        self.analyticType = type
    }
    
    func trackSelect(by amount: Int) {
        switch self.analyticType {
        case .topup:
            TrackingHelper.trackEvent("TopupQuickOption", value: ["SelectedAmount": amount])
        default:
            break
        }
    }

}
