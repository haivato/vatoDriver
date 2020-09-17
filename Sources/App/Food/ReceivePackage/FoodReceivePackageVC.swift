//  File name   : FoodReceivePackageVC.swift
//
//  Author      : vato.
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import SnapKit
import RxSwift

protocol FoodReceivePackagePresentableListener: FoodReceivePackageDetailListener {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func foodReceivePackageMoveBack()
    var bookInfo: Observable<FCBookInfo?> { get }
    var user : Observable<FCUser?> { get }
    var type : FoodReceivePackageType { get }
    func didSelectAction(action: FoodReceivePackageAction)
    func uploadImage()
    func removePhoto(index: Int)
    var eLoadingObser: Observable<(Bool, Double)> { get }
}

final class FoodReceivePackageVC: UIViewController, FoodReceivePackagePresentable, FoodReceivePackageViewControllable {
    private struct Config {
    }
    /// Class's public properties.
    weak var listener: FoodReceivePackagePresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        controllerDetail?.listener = listener
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    @IBOutlet private weak var sliderViewContainer: UIView?
    @IBOutlet private weak var avatarImageView: UIImageView?
    @IBOutlet private weak var userNameLabel: UILabel?
    @IBOutlet private weak var labelAppVersion: UILabel?
    @IBOutlet private weak var callButton: UIButton?
    @IBOutlet private weak var chatButton: UIButton?
    @IBOutlet weak var containerView: UIView!
    private var sliderView: MBSliderView = MBSliderView.createDefautTemplate()
    private lazy var disposeBag = DisposeBag()
    var controllerDetail: FoodReceivePackageDetail? {
           return children.compactMap { $0 as? FoodReceivePackageDetail }.first
       }
}

// MARK: View's event handlers
extension FoodReceivePackageVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension FoodReceivePackageVC {
    func showError(eror: Error) {
        AlertVC.showError(for: self, error: eror as NSError)
    }
    
    func showAlert(message: String) {
        AlertVC.showMessageAlert(for: self, title: "Lưu ý", message: message, actionButton1: "Hủy", actionButton2: nil, handler2:nil)
    }
}

// MARK: Class's private methods
private extension FoodReceivePackageVC {
    private func localize() {
        // todo: Localize view's here.
        self.title = "Chi tiết đơn hàng"
    }

    private func visualize() {
        // todo: Visualize view's here.
        let image = UIImage(named: "close")?.withRenderingMode(.alwaysOriginal)
        let rightBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightBarItem
        rightBarItem.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.foodReceivePackageMoveBack()
        }.disposed(by: disposeBag)
        
        self.sliderView.delegate = self
        sliderView.text = "TÔI ĐÃ LẤY HÀNG"
        self.sliderViewContainer?.addSubview(self.sliderView)
        self.sliderView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
            make.height.equalToSuperview()
        }
        
        self.sliderViewContainer?.backgroundColor = orangeColor
        let radius = (self.sliderViewContainer?.frame.size.height ?? 0)/2
        self.setViewRoundCorner(self.sliderViewContainer, withRadius: radius)
        
        //show appp information
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.labelAppVersion?.text = "\(UserDataHelper.shareInstance().userId()) | \(appVersion)"
        
        if listener?.type == .viewDetail {
            containerView.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func setupRX() {
        self.listener?.user.bind(onNext: { [weak self] (user) in
            self?.userNameLabel?.text = user?.getDisplayName()
            if let avatar = user?.avatarUrl,
                let avatarUrl = URL(string: avatar) {
                self?.avatarImageView?.setImageWith(avatarUrl, placeholderImage: UIImage(named: "avatar-placeholder"))
            }
        }).disposed(by: disposeBag)
        
        listener?.eLoadingObser.bind(onNext: { (value) in
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        self.listener?.bookInfo.bind(onNext: { [weak self] (booking) in
            //show appp information
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            self?.labelAppVersion?.text = "\(UserDataHelper.shareInstance().userId()) | \(appVersion) | \(booking?.tripCode ?? "")"
        }).disposed(by: disposeBag)
        
        let chat = self.callButton?.rx.tap.map { FoodReceivePackageAction.call }
        let message = self.chatButton?.rx.tap.map { FoodReceivePackageAction.message }
        Observable.merge([chat, message].compactMap { $0 })
            .bind(onNext: { [weak self](action) in
                self?.listener?.didSelectAction(action: action)
            }).disposed(by: disposeBag)
    }
}

extension FoodReceivePackageVC: MBSliderViewDelegate {
    func sliderDidSlide(_ slideView: MBSliderView!, shouldResetState reset: UnsafeMutablePointer<ObjCBool>!) {
        reset.pointee = true
        listener?.uploadImage()
    }
}
