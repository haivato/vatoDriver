//
//  PackageDetailVC.swift
//  FC
//
//  Created by vato. on 8/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import AXPhotoViewer

struct ImagePackageModel {
    enum type {
        case image
        case addNew
    }
    var image: UIImage?
}

@objc protocol PackageDetailListener: class {
    func didChangeListImageView(listImage: [Any])
}

class PackageDetailVC: UITableViewController {
    @objc weak var listener: PackageDetailListener?
    
    /// IBOutlet property
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var promotionBtn: UIButton!
    @IBOutlet private weak var vatoPayBtn: UIButton!
    @IBOutlet private weak var cashBtn: UIButton!
    
    @IBOutlet private var lblSupplyDesption: UILabel?
    @IBOutlet private var lblPriceSupplyEstimare: UILabel?
    @IBOutlet private var imageView: UIImageView?
    
    /// private property
    private var photosViewController: AXPhotosViewController?
    private var currentIndexAXPhoto: Int?
    var listImage: [ImagePackageModel] = [ImagePackageModel](){
        didSet {
            self.listener?.didChangeListImageView(listImage: self.listImage.compactMap({ $0.image }))
            if listImage.count > 3 {
                self.listImage.remove(at: listImage.count - 1)
            } else if listImage.count < 3 {
                var isNeedAppendAddImage = true
                self.listImage.forEach { (model) in
                    if model.image == nil {
                        isNeedAppendAddImage = false
                    }
                }
                if isNeedAppendAddImage == true {
                    self.listImage.append(ImagePackageModel())
                }
            }
            self.collectionView.reloadData()
        }
    }
    var bookInfo: FCBookInfo? {
        didSet { self.fillData(bookInfo: bookInfo) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.listImage = []

    }
    
    /// private method
    private func fillData(bookInfo: FCBookInfo?) {
        guard let bookInfo = bookInfo else { return }
        
        let totalFare = bookInfo.getBookPrice()
        let bookPrice = totalFare + bookInfo.additionPrice
        let promotion = bookInfo.promotionValue;
        let clientSupport = min(bookInfo.fareClientSupport + promotion, totalFare)
        let clientpay = max(bookPrice - clientSupport,0);
        let code = bookInfo.tripCode ?? ""
        let image = Utils.generateQRCode(from: code)
        imageView?.image = image
        lblSupplyDesption?.text = bookInfo.supplyInfo?.productDescription
        lblPriceSupplyEstimare?.text = "Giá ước tính: \((bookInfo.supplyInfo?.estimatedPrice ?? 0).currency)"
        
        let priceFormat = self.formatPrice(clientpay, withSeperator: ",")
        self.priceLabel.text = "\(priceFormat ?? "")đ"
        
        self.promotionBtn.isHidden = true
        if let promotionCode = bookInfo.promotionCode,
            promotionCode.count > 0 || bookInfo.fareClientSupport > 0 {
            self.promotionBtn.isHidden = false
        }
        
        if bookInfo.payment == PaymentMethodCash {
            self.vatoPayBtn.isHidden = true
        }
        
        if bookInfo.payment == PaymentMethodVATOPay {
            self.cashBtn.isHidden = true
        }
        if bookInfo.payment == PaymentMethodVisa || bookInfo.payment == PaymentMethodMastercard {
            self.cashBtn.isHidden = true
            self.vatoPayBtn.setTitle("Thẻ", for: .normal)
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    private func openCamera() {
        self.checkAuthorizeCamera {[weak self] (isAuthorize) in
            guard let self = self else { return }
            if isAuthorize {
                self.showImagePickerController()
            } else {
                AlertVC.showMessageAlert(for: self, title: "Lỗi", message: "Bạn cần cấp quyền mở camera để chụp hình.", actionButton1: "Đóng", actionButton2: nil)
            }
        }
    }
    
    func showImagePickerController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            AlertVC.showMessageAlert(for: self, title: "Lỗi", message: "Không thể mở camera", actionButton1: "Đóng", actionButton2: nil)
        }
    }
    
    private func checkAuthorizeCamera(completion: ((Bool) -> Void)?) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            mainAsync(block: completion)(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: mainAsync(block: completion))
        }
    }
}

/// table view delegate
extension PackageDetailVC {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

extension PackageDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagePackageCell
        let model = self.listImage[indexPath.row]
        if model.image == nil {
            cell.imageView.image = UIImage(named: "iconPhotoUpload")
            cell.buttonClear.isHidden = true
        } else {
            cell.imageView.image = model.image
            cell.buttonClear.isHidden = false
        }
        cell.didSelectClear = { [weak self] (sender) in
            if indexPath.row < self?.listImage.count ?? 0 {
                self?.listImage.remove(at: indexPath.row)
            }
        }
        return cell
    }
}

extension PackageDetailVC: UICollectionViewDelegate {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if bookInfo?.supplyInfo != nil {
            return UITableView.automaticDimension
        }
        
        if indexPath.section == 0 {
            return (bookInfo?.payment == PaymentMethodVATOPay) ? 217 : 150
        } else {
            return 142
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath.row >= self.listImage.count { return }
        let model = self.listImage[indexPath.row]
        if model.image == nil {
            self.openCamera()
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
            if let photosViewController = photosViewController {
                self.present(photosViewController, animated: true)
            }
        }
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
}

extension PackageDetailVC: AXPhotosViewControllerDelegate {
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              willUpdate overlayView: AXOverlayView,
                              for photo: AXPhotoProtocol,
                              at index: Int,
                              totalNumberOfPhotos: Int) {
        self.currentIndexAXPhoto = index
    }
}

extension PackageDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            var index = 0
            if self.listImage.count > 0 {
                index = self.listImage.count - 1
            }
            self.listImage.insert(ImagePackageModel(image: image.resize()), at: index)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}
