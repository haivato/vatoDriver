//
//  ViewShowService.swift
//  FC
//
//  Created by Phan Hai on 07/07/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewShowService: UIView {
    @objc var txService: String = ""
    private var disposeBag = DisposeBag()
    @IBOutlet weak var btService: UIButton!
    @IBOutlet weak var lbService: UILabel!
    private var obsTimer: PublishSubject<Bool> = PublishSubject.init()
    @objc var open: (()-> Void)?
    @objc var close: (()-> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.clipsToBounds = true
        self.layer.cornerRadius = 33
        lbService.text = ""
        setupRX()
    }
    
    private func setupRX() {
        self.btService.rx.tap.bind { [weak self] in
            guard let wSelf = self else { return }
            if wSelf.btService.isSelected {
                self?.obsTimer.onNext(false)
                wSelf.removeTextService()
            } else {
                wSelf.btService.isSelected = true
                wSelf.updateUIWhenPress()

            }
        }.disposed(by: disposeBag)
        
        self.obsTimer.asObserver()
            .debounce(RxTimeInterval.seconds(5), scheduler: MainScheduler.asyncInstance)
            .bind { (isActive) in
                guard isActive else  { return }
                self.removeTextService()
        }.disposed(by: disposeBag)
    }
    
    private func updateUIWhenPress() {
        self.lbService.text = self.txService
        self.open?()
        self.obsTimer.onNext(true)
    }
    private func removeTextService() {
        self.btService.isSelected = false
        self.lbService.text = ""
        self.close?()
    }
}
