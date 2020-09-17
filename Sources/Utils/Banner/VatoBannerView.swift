//  File name   : VatoBannerView.swift
//
//  Author      : Dung Vu
//  Created date: 6/2/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class VatoBannerView<E>: UIView, UpdateDisplayProtocol, HandlerEventReuseProtocol where E: ImageDisplayProtocol {
    var reuseEvent: Observable<Void>?
    
    /// Class's public properties.
    private lazy var imgView: UIImageView = UIImageView(frame: .zero)
    /// Class's private properties.
    private lazy var disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        backgroundColor = .clear
        self.clipsToBounds = true
        imgView >>> self >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: E?) {
        let task = imgView.setImage(from: item, placeholder: nil, size: CGSize(width: UIScreen.main.bounds.width, height: 64))
        reuseEvent?.take(1).bind(onNext: { (_) in
            task?.cancel()
        }).disposed(by: disposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else {
            return
        }
        visualize()
    }
}


// MARK: Class's private methods
private extension VatoBannerView {
    private func initialize() {
        // todo: Initialize view's here.
    }
}
