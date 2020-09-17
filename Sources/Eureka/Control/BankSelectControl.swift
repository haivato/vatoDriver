//  File name   : BankSelectControl.swift
//
//  Author      : Dung Vu
//  Created date: 11/8/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import Kingfisher

final class BankSelectControl: UIControl {
    /// Class's public properties.
    override var isSelected: Bool {
        didSet {
            imgViewSelect?.isHighlighted = isSelected
            self.sendActions(for: .valueChanged)
        }
    }
    
    var urlImage: URL? {
        didSet {
            self.iconImg?.kf.setImage(with: urlImage, placeholder: #imageLiteral(resourceName: "ic_bank"), options: [.fromMemoryCacheOrRefresh])
        }
    }
    
    var title: String? {
        didSet {
            self.lblDescription?.text = title
        }
    }
    
    var subTitle: String? {
        didSet {
            self.lblSubDescription?.text = subTitle
        }
    }
    
    /// Class's constructors.
    convenience init(with imgURL: URL?, title: String?, isSelected: Bool = false, arrow hide: Bool = false) {
        self.init(frame: .zero)
        initialize()
//        self.iconImg?.image = #imageLiteral(resourceName: "ic_bank")
        self.iconImg?.image = #imageLiteral(resourceName: "ic_wallet_cash")
        self.urlImage = imgURL
        self.title = title
        self.isSelected = isSelected
        self.arrowImg?.isHidden = true //hide
    }
    
    // MARK: Class's public methods
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    /// Class's private properties.
    var iconImg: UIImageView?
    var imgViewSelect: UIImageView?
    private var lblDescription: UILabel?
    private (set)var arrowImg: UIImageView?
    private var lblSubDescription: UILabel?
}

// MARK: Class's private methods
private extension BankSelectControl {
    private func initialize() {
        // todo: Initialize view's here.
        
        let imgCheck = #imageLiteral(resourceName: "ic_form_checkbox_uncheck")
        let checkImg = UIImageView.create {
            $0.contentMode = .scaleAspectFit
            $0.image = imgCheck
            $0.highlightedImage = #imageLiteral(resourceName: "ic_form_checkbox_checked")
            $0.isUserInteractionEnabled = false
            } >>> self >>> {
                $0.snp.makeConstraints({
                    $0.width.height.equalTo(22)
                })
        }
        
        imgViewSelect = checkImg
    
        let imgView = UIImageView.create {
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
            $0 >>> self >>> {
                $0.snp.makeConstraints({
                    $0.width.height.equalTo(40)
                })
            }
        }
        iconImg = imgView

        let lb1 = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.isUserInteractionEnabled = false
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        self.lblDescription = lb1
        
        let lb2 = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.isUserInteractionEnabled = false
        }
        self.lblSubDescription = lb2
            
        let labelStackView = UIStackView.create {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .fill
            $0.spacing = 5
            $0.addArrangedSubview(lb1)
            $0.addArrangedSubview(lb2)
        }
        
        let imagStackView = UIStackView.create {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 16
            $0.addArrangedSubview(imgView)
            $0.addArrangedSubview(labelStackView)
        }
        
        _ = UIStackView.create {
            $0 >>> self >>> {
                $0.snp.makeConstraints({
                    $0.leading.trailing.equalToSuperview().offset(16)
                    $0.top.bottom.equalToSuperview()
                })
            }
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 24
            $0.addArrangedSubview(checkImg)
            $0.addArrangedSubview(imagStackView)
        }
        
        _ = UIView.create {
            $0 >>> self >>> {
                $0.snp.makeConstraints {
                    $0.bottom.trailing.equalToSuperview()
                    $0.height.equalTo(1)
                    $0.leading.equalToSuperview().offset(118)
                }
            }
            $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        }
    }
}
