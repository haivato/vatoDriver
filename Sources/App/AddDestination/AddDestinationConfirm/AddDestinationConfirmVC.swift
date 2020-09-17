//  File name   : AddDestinationConfirmVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift
import RxCocoa

protocol AddDestinationConfirmPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var points: Observable<[DestinationPoint]> { get }
    var details: Observable<[DestinationPriceInfo]> { get }
    
    func updateRoute()
    func addDestinationMoveBack()
    
    func submitAddDestination()
    func dismissAddDestination()
}

final class AddDestinationConfirmVC: FormViewController, AddDestinationConfirmPresentable, AddDestinationConfirmViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: AddDestinationConfirmPresentableListener?
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .none
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    let btnCancel: UIButton = UIButton(frame: .zero)
    let btnAgree: UIButton = UIButton(frame: .zero)
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }

    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { return 0.1 }

    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
}

// MARK: View's event handlers
extension AddDestinationConfirmVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension AddDestinationConfirmVC {
}

// MARK: Class's private methods
private extension AddDestinationConfirmVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor(hexString: "0x00613D")
        navigationBar?.isTranslucent = false
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        title = "Thêm điểm đến"
        view.backgroundColor = .white
        // Add button
        btnCancel.applyButton(style: .cancel)
        btnCancel.setTitle("Huỷ", for: .normal)
        
        btnAgree.applyButton(style: .default)
        btnAgree.setTitle("Xác nhận", for: .normal)
        
        let stackView = UIStackView(arrangedSubviews: [btnCancel, btnAgree])
        stackView >>> view >>> {
            $0.distribution = .fillEqually
            $0.axis = .horizontal
            $0.spacing = 16
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-16)
                make.height.equalTo(56)
            }
        }
        
        // Table view
        tableView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(stackView.snp.top)
            }
        }
        let section = Section.init { (s) in
            s.tag = "Detail"
        }
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    func setupRX() {
        listener?.points.bind(onNext: weakify({ (points, wSelf) in
            guard let section = wSelf.form.sectionBy(tag: "Detail") else { return }
            points.enumerated().forEach { (p) in
                let cell = RowDetailGeneric<AddDestinationCell>.init("AddDestinationCell\(p.offset)") { (row) in
                    row.value = p.element
                    row.cell.setupDisplay(item: p.element)
                }
                section <<< cell
            }
        })).disposed(by: disposeBag)
        
        listener?.details.bind(onNext: weakify({ (details, wSelf) in
            guard let section = wSelf.form.sectionBy(tag: "Detail") else { return }
            let cell = RowDetailGeneric<AddDestinationPriceCell>.init("AddDestinationPriceCell") { (row) in
                row.value = details
                row.cell.setupDisplay(item: details)
            }
            section <<< cell
        })).disposed(by: disposeBag)
                        
        btnCancel.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.dismissAddDestination()
        })).disposed(by: disposeBag)
        
        btnAgree.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.submitAddDestination()
        })).disposed(by: disposeBag)
        
    }
}
