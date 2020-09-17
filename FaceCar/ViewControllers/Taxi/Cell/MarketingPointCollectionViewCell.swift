//
//  MarketingPointCollectionViewCell.swift
//  FC
//
//  Created by vato. on 2/19/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift

enum MarketingPointButtonType {
    case listDriver
    case pending
    case agree
    case reject
    case request
    case clear
}

class MarketingPointCollectionViewCell: UICollectionViewCell, UpdateDisplayProtocol {
    var didSelectButton: ((_ type: MarketingPointButtonType, TaxiOperationDisplay) -> Void)?
    
    enum MarketingPointType {
        case receiveRequest
        case requestPending
        case none
    }
    
    struct Config {
        static let colorHighlightLocation = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        static let fontTitleDefault = UIFont.systemFont(ofSize: 14)
        static let fontTitleHighlight = UIFont.systemFont(ofSize: 14, weight: .bold)
        static func setupButton(type: MarketingPointButtonType, button: UIButton) {
            switch type {
            case .listDriver:
                button.setTitle("Danh sách tài", for: .normal)
                button.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
            case .pending:
                button.setTitle("Chờ phản hồi", for: .normal)
                button.setTitleColor(#colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 1), for: .normal)
            case .agree:
                button.setTitle("Đồng ý", for: .normal)
                button.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), for: .normal)
            case .reject:
                button.setTitle("Từ chối", for: .normal)
                button.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
            case .request:
                button.setTitle("Yêu cầu xếp tài", for: .normal)
                button.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), for: .normal)
            default:
                break
            }
        }
    }
    
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var closeBtton: UIButton!
    
    private var leftButtonType :MarketingPointButtonType?
    private var rightButtonType :MarketingPointButtonType?
    private var currentItem :TaxiOperationDisplay?
    private lazy var disposeBag: DisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func didTouchClear(_ sender: Any) {
        guard let currentItem = currentItem else { return }
        didSelectButton?(.clear, currentItem)
    }
    
    @IBAction func touchLeftButton(_ sender: Any) {
        guard let currentItem = currentItem,
            let type = self.leftButtonType,
            type != .pending else { return }
        didSelectButton?(type, currentItem)
    }
    
    @IBAction func touchRighttButton(_ sender: Any) {
        guard let currentItem = currentItem,
            let type = self.rightButtonType,
            type != .pending else { return }
        didSelectButton?(type, currentItem)
    }
    
    func setupDisplay(item: TaxiOperationDisplay?) {
        currentItem = item
        resetDefaut()
        var text = "Bạn đang ở cách điểm tiếp thị \(item?.stationName ?? "")"
        self.closeBtton.isHidden = false
        self.rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        if item?.type == .watingResponse {
            if let itemId = item?.stationId {
                TOManageCommunication
                    .shared
                    .manageTimer[itemId]?
                    .takeUntil(self.rx.methodInvoked(#selector(prepareForReuse)))
                    .bind(onNext: { [weak self] (countDown) in
                        guard let wSelf = self else { return }
                        if countDown.remain > 0 {
                            let text = "Chờ phản hồi (\(countDown.remain)s)"
                            wSelf.rightButton.setTitle(text, for: .normal)
                            wSelf.rightButton.titleLabel?.numberOfLines = 2
                            wSelf.rightButton.titleLabel?.textAlignment = .center
//                            let s1 = "Chờ phản hồi ".attribute
//                            let s2 = "(\(countDown.remain)s)".attribute >>> .font(f: UIFont.systemFont(ofSize: 12, weight: .medium))
//                            wSelf.rightButton.titleLabel?.attributedText = s1 ~~> s2
                        } else {
                            wSelf.rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                            Config.setupButton(type: .pending, button: wSelf.rightButton)
                        }
                    }).disposed(by: disposeBag)
            }
            text = "Bạn đang ở cách điểm tiếp thị \(item?.stationName ?? "") \(item?.distance ?? "")"
            titleLabel.text = text
            titleLabel.attributedText = self.attributeHight(fullStr: text, subString: item?.stationName ?? "")
            self.closeBtton.isHidden = true
            setupView(type: .requestPending)
        } else  if item?.type == .invited {
            text = "Bạn nhận yêu cầu tham gia xếp tài điểm \(item?.stationName ?? "")"
            titleLabel.text = text
            titleLabel.attributedText = self.attributeHight(fullStr: text, subString: item?.stationName ?? "")
            setupView(type: .receiveRequest)
        } else {
            text = "Bạn đang ở cách điểm tiếp thị \(item?.stationName ?? "") \(item?.distance ?? "")"
            titleLabel.text = text
            titleLabel.attributedText = self.attributeHight(fullStr: text, subString: item?.stationName ?? "")
            setupView(type: .none)
        }
        titleLabel.text = text
        titleLabel.attributedText = self.attributeHight(fullStr: text, subString: item?.stationName ?? "")
    }
}

private extension MarketingPointCollectionViewCell {
    func attributeHight(fullStr: String, subString: String) -> NSAttributedString? {
        let range = (fullStr as NSString).range(of: subString)
        
        if range.location != NSNotFound {
            let attributedString = NSMutableAttributedString(string: fullStr, attributes: [
                .font: Config.fontTitleDefault,
                .foregroundColor: #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1),
                .kern: 0.0
            ])
            
            attributedString.addAttribute(.foregroundColor, value: Config.colorHighlightLocation, range: range)
            attributedString.addAttribute(.font, value: Config.fontTitleHighlight, range: range)
            return attributedString
        }
        return nil
    }
    
    func setupView(type: MarketingPointType) {
        switch type {
        case .receiveRequest:
            self.leftButtonType = .reject
            self.rightButtonType = .agree
            
            Config.setupButton(type: .reject, button: self.leftButton)
            Config.setupButton(type: .agree, button: self.rightButton)
        case .requestPending:
            self.leftButtonType = .listDriver
            self.rightButtonType = .pending
            
            Config.setupButton(type: .listDriver, button: self.leftButton)
            Config.setupButton(type: .pending, button: self.rightButton)
        default:
            resetDefaut()
        }
    }
    
    func resetDefaut() {
        self.leftButtonType = .listDriver
        self.rightButtonType = .request
        
        titleLabel.font = Config.fontTitleDefault
        titleLabel.textColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
        Config.setupButton(type: .listDriver, button: self.leftButton)
        Config.setupButton(type: .request, button: self.rightButton)
    }
}
