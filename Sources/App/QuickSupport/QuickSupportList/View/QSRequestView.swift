//
//  QSRequestView.swift
//  FC
//
//  Created by khoi tran on 1/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

protocol QSRequestViewHandlerProtocol: AnyObject {
    func selectImage(index: Int)
}

class QSRequestView: UIView, UpdateDisplayProtocol {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var requesTitleLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var requestMessageLabel: UILabel!
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var requestImageView: UIView!
    
    private lazy var disposeBag = DisposeBag()
    weak var listener: QSRequestViewHandlerProtocol?
    
    func setupDisplay(item: QuickSupportModel?) {
        codeLabel.text = ""
        requesTitleLabel.text = item?.title
        if let createdDate = item?.createdAt {
            createdDateLabel.text = createdDate.string(from: "HH:mm dd/MM/yyyy")
        }
        
        requestMessageLabel.text = item?.content
        statusLabel.text = item?.status?.string()
        statusLabel.textColor = item?.status?.titleColor()
        statusView.backgroundColor = item?.status?.bgColor()
        
        if let images = item?.images, !images.isEmpty {
            requestImageView.isHidden = false
            for view in imageStackView.arrangedSubviews {
                imageStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            images.enumerated().forEach { (index, image) in
                let options: KingfisherOptionsInfo = [.fromMemoryCacheOrRefresh, .transition(.fade(0.3))]
                let imageView = UIImageView.create {
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                    $0.cornerRadius = 6
                    $0.kf.setImage(with: URL(string: image), placeholder: nil, options: options)
                    $0.snp.makeConstraints { (make) in
                        make.width.equalTo(80)
                    }
                }
                
                let tapGesture = UITapGestureRecognizer()
                imageView.addGestureRecognizer(tapGesture)
                imageView.isUserInteractionEnabled = true
                tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
                    guard let me = self else { return }
                    me.listener?.selectImage(index: index)
                }).disposed(by: disposeBag)
                
                imageStackView.addArrangedSubview(imageView)
            }
        } else {
            requestImageView.isHidden = true
        }
    }
}
