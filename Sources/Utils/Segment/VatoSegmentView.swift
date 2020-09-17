//  File name   : VatoSegmentView.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

typealias VatoSegmentAdjust = (_ buton: UIButton, _ idx: Int) -> ()
@objcMembers
final class VatoSegmentView: UIView, Weakifiable {
    private let numberSegment: Int
    private let adjustButton: VatoSegmentAdjust
    private var buttons = [UIButton]()
    private (set)lazy var indicatorView: UIView = UIView(frame: .zero)
    private let space: CGFloat
    @Published private (set) var selected: Int
    private lazy var disposeBag = DisposeBag()
    
    init(numberSegment: Int, space: CGFloat, adjustButton: @escaping VatoSegmentAdjust) {
        self.numberSegment = numberSegment
        self.adjustButton = adjustButton
        self.space = space
        super.init(frame: .zero)
        visualize()
        setupRX()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Please Implement")
    }
    
    private func visualize() {
        precondition(numberSegment > 0, "Require number segment > 0")
        var events = [Observable<Int>]()

        (0..<numberSegment).forEach { (idx) in
            let button = UIButton(frame: .zero)
            adjustButton(button, idx)
            let e = button.rx.tap.map { _ in idx }
            events.append(e)
            buttons.append(button)
        }
        buttons.first?.isSelected = true
        
        let source = Observable.merge(events).distinctUntilChanged()
        source.bind(to: $selected).disposed(by: disposeBag)
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView >>> self >>> {
            $0.distribution = .fillEqually
            $0.spacing = space
            $0.axis = .horizontal
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        let count = CGFloat(buttons.count)
        indicatorView >>> self >>> {
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.bottom.equalToSuperview()
                make.height.equalTo(2)
                make.width.equalToSuperview().multipliedBy(1 / count).priority(.high)
            }
        }
    }
    
    private func setupRX() {
        $selected.bind(onNext: weakify({ (idx, wSelf) in
            wSelf.buttons.enumerated().forEach { $0.element.isSelected = $0.offset == idx }
            let idx = CGFloat(idx)
            let count = CGFloat(wSelf.numberSegment)
            let ratio = idx / count
            let w = wSelf.bounds.width
            let transform = CGAffineTransform(translationX: ratio * w, y: 0)
            UIView.animate(withDuration: 0.3) {
                wSelf.indicatorView.transform = transform
            }
        })).disposed(by: disposeBag)
    }
}


