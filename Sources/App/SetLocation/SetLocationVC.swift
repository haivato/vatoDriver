//  File name   : SetLocationVC.swift
//
//  Author      : khoi tran
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift

protocol SetLocationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var latestLocation: Observable<AddressProtocol> { get }
    var displayName: Observable<String> { get }
    
    func routeToChangeLocation()
    func setDefaultLocation()
    func openSetting()
}

final class SetLocationVC: UIViewController, SetLocationPresentable, SetLocationViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: SetLocationPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        UIApplication.setStatusBar(using: .default)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    /// Class's private properties.
    @IBOutlet private var lblAddress: UILabel!
    @IBOutlet private var lblUsername: UILabel!
    @IBOutlet private var lblDescription: UILabel!
    @IBOutlet private var btnChangeLocation: UIButton!
    @IBOutlet private var btnSetLocation: UIButton!
    @IBOutlet private var btnSetting: UIButton!
    @IBOutlet private var lblPreviousLocation: UILabel!
    
    private var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension SetLocationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension SetLocationVC {
}

// MARK: Class's private methods
private extension SetLocationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.lblDescription.text = "Bạn có thể bỏ qua bước này, hãy cho phép VATO truy cập vào vị trí của bạn."
        self.btnChangeLocation.setTitle("Thay đổi", for: .normal)
        self.btnSetLocation.setTitle("Sử dụng vị trí này", for: .normal)
        self.btnSetting.setTitle("Cho phép truy cập định vị", for: .normal)
        self.lblPreviousLocation.text = "Vị trí đã nhập trước đó"
    }
    
    func setupRX() {
        self.listener?.latestLocation.bind(onNext: weakify({ (location, wSelf) in
            wSelf.lblAddress.text = location.name
        })).disposed(by: disposeBag)
                
        self.btnChangeLocation.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToChangeLocation()
        })).disposed(by: disposeBag)
        
        self.btnSetLocation.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.setDefaultLocation()
        })).disposed(by: disposeBag)
        
        self.btnSetting.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.openSetting()
                        
        })).disposed(by: disposeBag)
        
        self.listener?.displayName.bind(onNext: { (name) in
            self.lblUsername.text = String(format: "Chào %@, bạn còn ở đây không?", name)
        }).disposed(by: disposeBag)
        
    }
}
