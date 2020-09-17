//
//  PackageInfoVC.swift
//  
//
//  Created by vato. on 8/21/19.
//

import UIKit
import RxSwift
import SVProgressHUD

@objc protocol PackageInfoListener: class {
    func didSelectCall()
    func didSelectChat()
    func packageInfoDidSelectContinue(sender: PackageInfoVC)
}

final class PackageInfoVC: UIViewController {
    @objc weak var listener: PackageInfoListener?
    
    @IBOutlet private weak var sliderViewContainer: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var labelAppVersion: UILabel!
    private var sliderView: MBSliderView!
    private lazy var firebaseDatabase = Database.database().reference()
    private lazy var disposeBag: DisposeBag = DisposeBag()
    @objc var bookingService: FCBookingService?
    
    var controllerDetail: PackageDetailVC? {
        return children.compactMap { $0 as? PackageDetailVC }.first
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Thông tin gói hàng"
        self.controllerDetail?.bookInfo = self.bookingService?.book.info
        self.findClient(firebaseId: self.bookingService?.book.info.clientFirebaseId).subscribe(onNext: { [weak self] (user) in
            if let avatar = user.avatarUrl,
               let avatarUrl = URL(string: avatar) {
               self?.avatarImageView.setImageWith(avatarUrl, placeholderImage: UIImage(named: "avatar-placeholder"))
                self?.userNameLabel.text = user.getDisplayName()
            }
        }).disposed(by: disposeBag)
        
        self.bookingService?.rx.observe(FCBooking.self, #keyPath(FCBookingService.book)).bind(onNext: weakify({ (book, wSelf) in
            guard let b = book else { return }
            wSelf.controllerDetail?.bookInfo = b.info
        })).disposed(by: disposeBag)
        
        self.sliderView = MBSliderView.createDefautTemplate()
        self.sliderView.delegate = self
        sliderView.text = "BẮT ĐẦU GIAO HÀNG"
        self.sliderViewContainer.addSubview(self.sliderView)
        
        self.sliderViewContainer.backgroundColor = orangeColor
        self.setViewRoundCorner(self.sliderViewContainer, withRadius: self.sliderViewContainer.frame.size.height/2)
        
        self.controllerDetail?.listener = self
        
        //show appp information
        let tripID = self.bookingService?.book.info.tripId ?? ""
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.labelAppVersion.text = "\(UserDataHelper.shareInstance().userId()) | \(appVersion) | \(tripID)"
    }
    
    func findClient(firebaseId: String?) -> Observable<FCUser> {
        guard let firebaseId = firebaseId else { return Observable.empty() }
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        return firebaseDatabase.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<FCUser> in
                let user = try FCUser(dictionary: snapshot.value as? [AnyHashable : Any])
                return Observable.just(user)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rect = self.sliderViewContainer.frame
        self.sliderView.frame = CGRect(x: 10, y: 0, width: rect.size.width - 20.0, height: rect.size.height)
    }
    
    @IBAction func didTouchCall(_ sender: Any) {
        self.listener?.didSelectCall()
    }
    
    @IBAction func didTouchChat(_ sender: Any) {
        self.listener?.didSelectChat()
    }
    
}

extension PackageInfoVC: MBSliderViewDelegate {
    func sliderDidSlide(_ slideView: MBSliderView!, shouldResetState reset: UnsafeMutablePointer<ObjCBool>!) {
        reset.pointee = true
        guard let listImage = self.controllerDetail?.listImage.compactMap({ $0.image }),
            listImage.count > 0 else {
                AlertVC.showMessageAlert(for: self, title: "Lưu ý", message: "Cần chụp ít nhất 1 hình biên nhận để tiếp tục giao hàng!", actionButton1: "Hủy", actionButton2: nil, handler2:nil)
                return
        }
        if let book = self.bookingService?.book,
            let tripId = book.info.tripId {
            LoadingManager.instance.show()
            UIApplication.shared.beginIgnoringInteractionEvents()
            FirebaseUploadImage.upload(listImage, withPath: tripId) {[weak self] (urls, error) in
                DispatchQueue.main.async {
                    if error != nil,
                        let _error = error as NSError? {
                        // show error
                        AlertVC.showError(for: self, error: _error)
                    } else {
                        let resultURLs = urls.compactMap { url -> URL? in
                            var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
                            let queries = component?.queryItems?.filter { $0.name != "token"}
                            component?.queryItems = queries
                            return component?.url
                        }
                        self?.updateURLs(resultURLs.compactMap({ $0.absoluteString }))
                    }
                    UIApplication.shared.endIgnoringInteractionEvents()
                    LoadingManager.instance.dismiss()
                }
            }
        }
    }
    
    private func updateURLs(_ urls: [String]) {
        self.bookingService?.updateInfoReceiveImages(urls)
        let book = self.bookingService?.book
        self.bookingService?.updateLastestBookingInfo(book, block: { [weak self]_ in
            guard let wSelf = self else {
                return
            }
            wSelf.updateStatus(Int(BookStatusDeliveryReceivePackageSuccess.rawValue))
        })
    }
    
    private func updateStatus(_ status: Int) {
        self.bookingService?.updateBookStatus(status, complete: { [weak self] (success) in
            guard success else { return }
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.packageInfoDidSelectContinue(sender: wSelf)
            wSelf.dismiss(animated: false, completion: nil)
        })
    }
}

extension PackageInfoVC: PackageDetailListener {
    func didChangeListImageView(listImage: [Any]) {
    }
}
