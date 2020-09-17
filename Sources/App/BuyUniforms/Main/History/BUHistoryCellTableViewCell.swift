//
//  BUHistoryCellTableViewCell.swift
//  FC
//
//  Created by vato. on 3/13/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BUHistoryCellTableViewCell: UITableViewCell, UpdateDisplayProtocol {
    
    @IBOutlet weak var imageQRCode: UIImageView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var orderCodeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var nameLocationLabel: UILabel!
    @IBOutlet weak var addressLocationLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var viewAction: UIView!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var lblMethod: UILabel?
    @IBOutlet weak var bgMethod: UIView?
    
    private lazy var disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupDisplay(item: SalesOrder?) {
        self.imageQRCode.image = nil
        QRImageGenerate.loadImage(by: item?.id ?? "").takeUntil(self.rx.methodInvoked(#selector(prepareForReuse))).filterNil().bind(onNext: { (url) in
            self.imageQRCode.setImage(from: url.absoluteString, placeholder: nil, size: CGSize(width: 100, height: 100))
        }).disposed(by: disposeBag)
            
//            Utils.generateQRCode(from: item?.id ?? "")
        let date = Date(timeIntervalSince1970: (item?.createdAt ?? 0)/1000)
        self.dateTimeLabel.text = date.string(from: "HH:mm dd/MM/yyyy")
        self.orderCodeLabel.text = "\(item?.code ?? "")"
        self.nameLocationLabel.text = item?.orderItems?.first?.nameStore
        self.addressLocationLabel.text = item?.orderItems?.first?.addressStore
        self.priceLabel.text = (item?.grandTotal ?? 0).currency
        
        let views = stackView.arrangedSubviews
        if !views.isEmpty {
            views.forEach { (v) in
                stackView.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
        }
        item?.orderItems?.forEach { (i) in
            let v = BUInfoOrderView.loadXib()
            v.backgroundColor = .clear
            v.titleLabel.text = i.name
            v.quantityLabel.text = "x\(i.qty ?? 1)"
            let price = Double(i.basePriceInclTax ?? 0)
            v.priceLabel.text = price.currency
            stackView.addArrangedSubview(v)
        }
        
        self.statusView.backgroundColor = item?.state?.bgColor
        self.statusLabel.textColor = item?.state?.txtColor
        self.statusLabel.text = item?.state?.stringValue
        var paymentType: PaymentCardType = .cash
        if let p = item?.salesOrderPayments?.first?.paymentMethod, let type = PaymentCardType(rawValue: p) {
            paymentType = type
        }
        
        lblMethod?.text = paymentType.generalName.uppercased()
        bgMethod?.backgroundColor = paymentType.color
        
        self.viewAction.isHidden = false
        self.signButton.isHidden = true
        if let state = item?.state {
            switch state {
            case .CANCELED:
                self.viewAction.isHidden = true
                self.signButton.isHidden = true
            case .NEW:
                self.viewAction.isHidden = false
                self.signButton.isHidden = true
            case .PAYMENT:
                self.viewAction.isHidden = false
                self.signButton.isHidden = false
            case .COMPLETE:
                self.viewAction.isHidden = true
                self.signButton.isHidden = true
            }
        }
    }
}
