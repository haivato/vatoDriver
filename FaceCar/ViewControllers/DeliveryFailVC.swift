//
//  DeliveryFailVC.swift
//  FC
//
//  Created by THAI LE QUANG on 8/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD
import VatoNetwork
import FwiCoreRX
import Alamofire
import Firebase
import SnapKit
import AXPhotoViewer

enum DeliveryFailType: Int, CustomStringConvertible {
    
    case deliveryFail
    case cancelBooking
    
    var title: String {
        switch self {
        case .deliveryFail:
            return "Giao hàng thất bại"
        case .cancelBooking:
            return "Huỷ chuyến"
        }
    }
    
    var subTitle: String {
        switch self {
        case .deliveryFail:
            return "Lý do giao hàng thất bại"
        case .cancelBooking:
            return "Lý do huỷ"
        }
    }
    
    var keyJson: String {
        switch self {
        case .deliveryFail:
            return "delivery_failed_reasons"
        case .cancelBooking:
            return "trip_canceled_reasons"
        }
    }
    
    var description: String {
        return ""
    }
}

class DeliveryFailVC: UIViewController {
    
    private struct Config {
        static let maximumPhoto = 3
    }
    
    @objc var didSelectConfirm: ((_ param: [String: Any]) -> Void)?
    
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet private weak var labelAppVersion: UILabel!
    
    /// Class's private properties.
    private lazy var firebaseDatabase = Database.database().reference()
    private(set) lazy var disposeBag = DisposeBag()
    private var dataSource: [FirebaseModel.DeliveryReasonItem]?
    
    private var lblSubTitle: UILabel!
    private var viewFooter: UIView!
    private var tfNote: UITextField!
    @IBOutlet weak var vBottom: UIView!
    private var collectionView: UICollectionView!
    @IBOutlet weak var stackViewBottom: UIStackView!
    private var lblTitle: UILabel = UILabel(frame: .zero)
    var listImage: [ImageRequestModel] = [ImageRequestModel]()
    private lazy var pickerImageHandler = PickerImageHandler()
    private var photosViewController: AXPhotosViewController?
    private var currentIndexAXPhoto: Int?
    @VariableReplay private var images: [UIImage] = []
    @IBOutlet weak var hViewBottom: NSLayoutConstraint!
    @objc var bookingService: FCBookingService?
    var tripID = ""
    
    private var viewType: DeliveryFailType = .deliveryFail
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        createFooterView()
        requestData()
        
        //show appp information
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.labelAppVersion.text = "\(UserDataHelper.shareInstance().userId()) | \(appVersion) | \(tripID)"
        
        //setup lb & collection
        
        let tagCellLayout = UICollectionViewFlowLayout()
        tagCellLayout.minimumLineSpacing = 0
        tagCellLayout.minimumInteritemSpacing = 0
        tagCellLayout.scrollDirection = .horizontal
        tagCellLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 13)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagCellLayout)
        
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView >>> self.vBottom >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(16)
                make.top.equalToSuperview().inset(26)
                make.bottom.equalTo(self.stackViewBottom.snp.top).inset(-16)
            })
        }
        
        collectionView.register(AddImageCell.nib, forCellWithReuseIdentifier: "AddImageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        lblTitle >>> self.vBottom >>> {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.text = "Hình ảnh đính kèm (tối đa 3 ảnh)"
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(self.collectionView).inset(10)
                make.bottom.equalTo(self.collectionView.snp.top).inset(-5)
            }
        }
        
        if self.viewType == .cancelBooking {
            collectionView.removeFromSuperview()
            lblTitle.removeFromSuperview()
            self.hViewBottom.constant = 80
        } else {
            collectionView.isHidden = false
            self.hViewBottom.constant = 178
        }
        
        setRX()
    }
    
    @objc static func generateTypeCancelBooking() -> DeliveryFailVC {
        let vc = DeliveryFailVC()
        vc.updateTypeViewController(with: .cancelBooking)
        return vc
    }
    
    @objc func setTripID(with ID: String) {
        self.tripID = ID
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tfNote.resignFirstResponder()
    }
    
    // MARK: - Public methods
    func updateTypeViewController(with type: DeliveryFailType) {
        self.viewType = type
    }
    
    // MARK: - Private methods
    private func setupNavigationBar() {
        UIApplication.setStatusBar(using: .lightContent)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        self.title = self.viewType.title
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBar?.shadowImage = UIImage()
        
        if #available(iOS 12, *) {
        } else {
            navigationBar?.subviews.flatMap { $0.subviews }.filter{ $0 is UIImageView }.forEach({
                $0.isHidden = true
            })
        }
        
        UIApplication.setStatusBar(using: .lightContent)
    }
    
    private func setRX() {
        self.contentTableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.contentTableView.rx.setDataSource(self).disposed(by: disposeBag)
        self.contentTableView.register(UINib(nibName: "DeliveryFailTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "DeliveryFailTableViewCell")
        
        self.contentTableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            
            wSelf.btnConfirm.isEnabled = true
            wSelf.btnConfirm.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            
            let detail = wSelf.dataSource?[indexPath.row]

            if detail?.showOtherReason ?? false {
                wSelf.showViewFooter()
            }
        }.disposed(by: disposeBag)
        
        self.contentTableView.rx.itemDeselected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            
            let detail = wSelf.dataSource?[indexPath.row]
            if detail?.showOtherReason ?? false {
                wSelf.contentTableView.tableFooterView = nil
                wSelf.tfNote.resignFirstResponder()
            }
        }.disposed(by: disposeBag)
        
        self.btnCancel.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        self.btnConfirm.rx.tap.bind { [weak self] in
            guard let wSelf = self, let datas = wSelf.dataSource else { return }
            
            if self?.images.count ?? 0 < 1 && wSelf.viewType == .deliveryFail {
                AlertVC.showError(for: wSelf, message: "Cần chụp ít nhất 1 hình biên nhận để tiếp tục giao hàng!")
                return
            }
            
            if !wSelf.isNetworkAvailable() {
                AlertVC.showError(for: wSelf, message: "Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra và thử lại.");
                return
            }
            
            guard let indexPath: IndexPath =  wSelf.contentTableView.indexPathForSelectedRow else { return }
            
            var result: [String : Any] = [:]
            
            let row = indexPath.row
            let reason = datas[row]
            if row != datas.count - 1 {
                result = ["end_reason_id": reason.id ?? 0,
                          "end_reason_value": reason.value ?? ""]
            } else {
                let note = wSelf.tfNote.text ?? ""
                result = ["end_reason_id": reason.id ?? 0,
                          "end_reason_value": note]
            }
            
            if wSelf.viewType == .cancelBooking {
                self?.didSelectConfirm?(result)
                LoadingManager.instance.dismiss()
            }
            
            FirebaseUploadImage.upload(self?.images ?? [], withPath: "delivery_fail") {[weak self] (urls, error) in
                DispatchQueue.main.async {
                    if error != nil,
                        let _error = error as NSError? {
                        // show error
                        AlertVC.showError(for: wSelf, message: _error.localizedDescription)
                    } else {
                        let resultURLs = urls.compactMap { url -> URL? in
                            var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
                            let queries = component?.queryItems?.filter { $0.name != "token"}
                            component?.queryItems = queries
                            return component?.url
                        }
                        self?.bookingService?.updateInfoDeliverFailImages(resultURLs.compactMap { $0.absoluteString })
                        self?.didSelectConfirm?(result)
                    }
                    LoadingManager.instance.dismiss()
                }
            }
            
        }.disposed(by: disposeBag)
        
        setupKeyboardAnimation()
        
        self.$images.bind(onNext: weakify { (images, wSelf) in
            wSelf.reloadData(_images: images)
        }).disposed(by: disposeBag)
        
        pickerImageHandler.events.debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).bind { [weak self](type) in
            guard let wSelf = self else { return}
            switch type {
            case .image(let i):
                wSelf.images.append(i?.resize() ?? UIImage())
            case .cancel:
                break
            }
        }.disposed(by: disposeBag)
    }
    func showViewFooter() {
        self.contentTableView.tableFooterView = self.viewFooter
        self.tfNote.becomeFirstResponder()
        
        if self.tfNote.text == "" {
            self.btnConfirm.isEnabled = false
            self.btnConfirm.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        } else {
            self.btnConfirm.isEnabled = true
            self.btnConfirm.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        }
    }
    
    func requestData() {
        let node = FireBaseTable.master >>> FireBaseTable.appConfigure >>> FireBaseTable.custom(identify: "delivery_config")
        firebaseDatabase.find(by: node, type: .value, using: { ref in
            ref.keepSynced(true)
            
            return ref
        }).subscribe(onNext: { [weak self](snapshot) in
            guard let wSelf = self else { return }
            
            let children = try? FirebaseModel.DeliveryConfig.create(from: snapshot)
            if  wSelf.viewType == .deliveryFail {
                wSelf.dataSource = children?.delivery_failed_reasons
            } else {
                wSelf.dataSource = children?.trip_canceled_reasons
            }
            
            wSelf.contentTableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func createFooterView() {
        viewFooter = UIView.create {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 90))
            $0.backgroundColor = .white
        }
        
        let label = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.text = "Mô tả chi tiết"
            } >>> viewFooter >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(16)
                })
        }
        
        tfNote = UITextField.create {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
            $0.borderStyle = .none
            $0.placeholder = "Mô tả chi  tiết vấn đề của bạn"
            $0.returnKeyType = .done
            $0.delegate = self
            $0.addTarget(self, action: #selector(self.textFieldDidChange(sender:)), for: .editingChanged)
            } >>> viewFooter >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.top.equalTo(label.snp.bottom).offset(8)
                    make.height.equalTo(24)
                })
        }
        
        UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            } >>> viewFooter >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(0)
                    make.top.equalTo(tfNote.snp.bottom).offset(8)
                    make.height.equalTo(1)
                })
        }
    }
    func reloadData(_images: [UIImage]) {
        var images = _images.compactMap{ ImageRequestModel(image: $0, type: .image) }
        
        if images.count < Config.maximumPhoto {
            images.append(ImageRequestModel(image: nil, type: .addNew))
        }
        self.listImage = images
        self.collectionView.reloadData()
    }
    
    func update(title: String?) {
        lblTitle.text = title
    }
}

extension DeliveryFailVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DeliveryFailTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DeliveryFailTableViewCell
        if cell == nil {
            cell = DeliveryFailTableViewCell.newCell(reuseIdentifier: identifier)
        }
        
        cell?.visulizeCell(with: dataSource?[indexPath.row].value)
        
        return cell!
    }
}

extension DeliveryFailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.create {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 50))
            $0.backgroundColor = .white
        }
        
        UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.text = self.viewType.subTitle
            
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(16)
                })
        }
        return view
    }
}

extension DeliveryFailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfNote.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(sender: UITextField){
        if tfNote.text == "" {
            self.btnConfirm.isEnabled = false
            self.btnConfirm.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        } else {
            self.btnConfirm.isEnabled = true
            self.btnConfirm.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        }
    }
}

extension DeliveryFailVC: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return contentTableView
    }
}
extension DeliveryFailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCell", for: indexPath) as? AddImageCell else {
            fatalError("Error")
        }
        let model = self.listImage[indexPath.row]
        if model.type == .addNew {
            cell.imageView.image = UIImage(named: "iconPhotoUpload")
            cell.buttonClear.isHidden = true
        } else {
            cell.imageView.image = model.image
            cell.buttonClear.isHidden = false
        }
        cell.didSelectClear = { [weak self] (sender) in
            self?.removePhoto(index: indexPath.row)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    private func removePhoto(index: Int) {
        guard index >= 0,
            index < listImage.count else { return }
        self.images.remove(at: index)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.listImage[safe: indexPath.row] else {
            return
            
        }
        
        if model.type == .addNew {
            self.showAlert()
        } else {
            let photos = self.listImage.compactMap { (model) -> AXPhoto? in
                if let image = model.image {
                    return AXPhoto(attributedTitle: nil, attributedDescription: nil, attributedCredit: nil, imageData: nil, image: image, url: nil)
                }
                return nil
            }
            
            let cell = collectionView.cellForItem(at: indexPath) as? ImagePackageCell
            let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: cell?.imageView) { [weak self] (photo, index) -> UIImageView? in
                guard let wself = self else { return nil }
                
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = wself.collectionView.cellForItem(at: indexPath) as? ImagePackageCell else { return nil }
                return cell.imageView
            }
            self.currentIndexAXPhoto = indexPath.row
            let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: indexPath.row)
            photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)
            photosViewController?.delegate = self
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let bottomView = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))
            bottomView.items = [
                flex,
                UIBarButtonItem(barButtonSystemItem: .trash,
                                target: self,
                                action: #selector(deleteImage(sender:)))
            ]
            bottomView.backgroundColor = .clear
            bottomView.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            photosViewController?.overlayView.bottomStackContainer.insertSubview(bottomView, at: 0)
            photosViewController?.modalPresentationStyle = .fullScreen
            if let photosViewController = photosViewController {
                self.present(photosViewController, animated: true, completion: nil)
            }
        }
    }
    func showAlert(){
        //        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //        let btPhoto: UIAlertAction = UIAlertAction(title: "Chọn hình từ thư viện", style: .default) { _ in
        //            self.showLibrary(action: .photoLibrary)
        //        }
        //        let btCamera: UIAlertAction = UIAlertAction(title: "Chọn hình từ Camera", style: .default) { _ in
        //            self.checkAuthorizeCamera {[weak self] (isAuthorize) in
        //                guard let self = self else { return }
        //                if isAuthorize {
        //                    self.showLibrary(action: .camera)
        //                } else {
        //                    AlertVC.showError(for: self, message: "Bạn cần cấp quyền mở camera để chụp hình.")
        //                }
        //            }
        //
        //        }
        //        let btCancel: UIAlertAction = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
        //        alert.addAction(btPhoto)
        //        alert.addAction(btCamera)
        //        alert.addAction(btCancel)
        //        self.present(alert, animated: true, completion: nil)
        self.checkAuthorizeCamera {[weak self] (isAuthorize) in
            guard let self = self else { return }
            if isAuthorize {
                self.showLibrary(action: .camera)
            } else {
                AlertVC.showError(for: self, message: "Bạn cần cấp quyền mở camera để chụp hình.")
            }
        }
        
    }
    func showLibrary(action: UIImagePickerController.SourceType) {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = pickerImageHandler
        pickerVC.sourceType = action
        pickerVC.modalTransitionStyle = .coverVertical
        pickerVC.modalPresentationStyle = .fullScreen
        
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    @objc func deleteImage(sender: UIBarButtonItem) {
        if let index = self.currentIndexAXPhoto {
            self.listImage.remove(at: index)
            self.collectionView.reloadData()
            
            let photos = self.listImage.compactMap { (model) -> AXPhoto? in
                if let image = model.image {
                    return AXPhoto(attributedTitle: nil, attributedDescription: nil, attributedCredit: nil, imageData: nil, image: image, url: nil)
                }
                return nil
            }
            if photos.count == 0 {
                photosViewController?.dismiss(animated: false)
                return
            }
            
            let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: 0)
            photosViewController?.dataSource = dataSource
        }
    }
    func checkAuthorizeCamera(completion: ((Bool) -> Void)?) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            mainAsync(block: completion)(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: mainAsync(block: completion))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:80, height: 80)
    }
}
extension DeliveryFailVC: AXPhotosViewControllerDelegate {
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              willUpdate overlayView: AXOverlayView,
                              for photo: AXPhotoProtocol,
                              at index: Int,
                              totalNumberOfPhotos: Int) {
        self.currentIndexAXPhoto = index
    }
}
