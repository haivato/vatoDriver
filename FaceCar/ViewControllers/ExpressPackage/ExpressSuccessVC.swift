//
//  ExpressSuccessVC.swift
//  
//
//  Created by vato. on 8/21/19.
//

import UIKit
import RxSwift
import SVProgressHUD

@objc protocol ExpressSuccessListener: class {
    func expressSuccessDidSelectContinue(sender: ExpressSuccessVC)
}

class ExpressSuccessVC: UIViewController {
    @IBOutlet private weak var labelAppVersion: UILabel!
    
    @objc weak var listener: ExpressSuccessListener?
    
    private var sliderView: MBSliderView!
    private lazy var firebaseDatabase = Database.database().reference()
    private lazy var disposeBag: DisposeBag = DisposeBag()
    @objc var bookingService: FCBookingService?
    
    var controllerDetail: ExpressSuccessDetailVC? {
        return children.compactMap { $0 as? ExpressSuccessDetailVC }.first
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Giao hàng thành công"
        self.controllerDetail?.bookInfo = self.bookingService?.book.info
        
        //show appp information
        let tripID = self.bookingService?.book.info.tripId ?? ""
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.labelAppVersion.text = "\(UserDataHelper.shareInstance().userId()) | \(appVersion) | \(tripID)"
    }
    
    @IBAction func didTouchCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTouchConfirm(_ sender: Any) {
        guard let listImage = self.controllerDetail?.listImage.compactMap({ $0.image }),
            listImage.count > 0 else {
                AlertVC.showMessageAlert(for: self, title: "Lưu ý", message: "Cần chụp ít nhất 1 hình biên nhận để hoàn thành giao hàng!", actionButton1: "Hủy", actionButton2: nil, handler2:nil)
                return
        }
        if let book = self.bookingService?.book,
            let tripId = book.info.tripId {
            LoadingManager.instance.show()
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
                        self?.bookingService?.updateInfoDeliverImages(resultURLs.compactMap({ $0.absoluteString }))
                        self?.bookingService?.updateLastestBookingInfo(self?.bookingService?.book, block: { _ in
                            self?.bookingService?.updateBookStatus(Int(BookStatusCompleted.rawValue), complete: { (isSucess) in
                                if let wself = self {
                                    self?.listener?.expressSuccessDidSelectContinue(sender: wself)
                                }
                            })
                        });
                    }
                    LoadingManager.instance.dismiss()
                }
            }
        }
    }
}
