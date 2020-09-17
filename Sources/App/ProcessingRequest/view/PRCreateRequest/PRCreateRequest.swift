//
//  CreateRequest.swift
//  FC
//
//  Created by MacbookPro on 4/3/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import FwiCoreRX
import AXPhotoViewer

class PRCreateRequest: UIView {

    private struct Config {
      static let maximumPhoto = 3
    }
    
    var didSelectClear: ((_ indexPath: IndexPath) -> Void)?
    var didSelectAdd: (() -> Void)?
    var didSelectOpen: ((_ photo: AXPhotosViewController) -> Void)?
    @IBOutlet weak var btConfirm: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hBottomTV: NSLayoutConstraint!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var bBtnConfirm: NSLayoutConstraint!
    @IBOutlet weak var btDismiss: UIButton!
    @IBOutlet weak var hBtDismiss: NSLayoutConstraint!
    var listRequest: PublishSubject<[UserRequestTypeFireStore]> = PublishSubject.init()
    private var collectionView: UICollectionView!
    var listImage: [ImageRequestModel] = [ImageRequestModel]()
    private var listShowData : [UserRequestTypeFireStore] = []
    private var lblTitle: UILabel = UILabel(frame: .zero)
    private var photosViewController: AXPhotosViewController?
    private var currentIndexAXPhoto: Int?
    private let disposeBag = DisposeBag()
    var headerView: PRHeaderView = PRHeaderView.loadXib()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.tvContent.text = "Nhập nội dung lí do"
        tableView.delegate = self
        tableView.register(PRCreateRequestCell.nib, forCellReuseIdentifier: PRCreateRequestCell.identifier)
        tvContent.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        self.btConfirm.isEnabled = false
        
        let tagCellLayout = UICollectionViewFlowLayout()
        tagCellLayout.minimumLineSpacing = 0
        tagCellLayout.minimumInteritemSpacing = 0
        tagCellLayout.scrollDirection = .horizontal
        tagCellLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 13)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagCellLayout)
        
        visualize()
        collectionView.register(AddImageCell.nib, forCellWithReuseIdentifier: "AddImageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        setupRX()
        
        
    }
    private func setupRX() {
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }

        Observable.merge([showEvent, hideEvent]).filterNil().bind { (keyboard) in
            let h = keyboard.height
            UIView.animate(withDuration: 0.5) {
                self.bBtnConfirm.constant = (h > 0) ? ( h + 10) : 50
                self.hBottomTV.constant = (h > 0) ? 20 : 130
                self.hBtDismiss.constant = (h > 0) ? 20 : 101
                self.layoutIfNeeded()
            }
        }.disposed(by: disposeBag)
        
        self.listRequest.bind(to: tableView.rx.items(cellIdentifier: PRCreateRequestCell.identifier, cellType: PRCreateRequestCell.self)) {[weak self] (row, element, cell) in
            cell.lbTitle.text = element.title
        }.disposed(by: disposeBag)
        
        self.listRequest.asObserver().bind { [weak self] list in
                    guard let wSelf = self else { return }
            wSelf.listShowData = list
                }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            if let text = wSelf.listShowData[indexPath.row].imageUploadDescription {
                wSelf.lblTitle.text = text
            } else {
                wSelf.lblTitle.text = Text.limitImage.localizedText
            }
            
        }.disposed(by: disposeBag)
        
        self.btDismiss.rx.tap.bind { _ in
            self.endEditing(true)
        }.disposed(by: disposeBag)
        
    }
    private func visualize() {
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(16)
                make.top.equalTo(self.tvContent.snp.bottom).inset(-16)
                make.bottom.equalTo(self.btConfirm.snp.top).inset(-16)
            })
        }
        
        lblTitle >>> self >>> {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(self.collectionView).inset(10)
                make.bottom.equalTo(self.collectionView.snp.top).inset(4)
            }
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
    
//    func setupRX() { }

    func setupDisplay(item: String?) {}
}
extension PRCreateRequest: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 180
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        
        v.addSubview(self.headerView)
        self.headerView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
        }
        
        let title: UILabel = UILabel()
        title.text = Text.confirmSupport.localizedText
        title.font = UIFont.systemFont(ofSize: 14)
        title.textColor =  #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        
        v.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.left.equalTo(v).inset(24)
            make.bottom.equalTo(v).inset(10)
        }
        
        let btDismiss: UIButton = UIButton(type: .system)
        btDismiss.backgroundColor = .clear
        v.addSubview(btDismiss)
        btDismiss.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        btDismiss.rx.tap.bind { _ in
            self.endEditing(true)
        }.disposed(by: disposeBag)
        
        return v
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.btConfirm.isEnabled = true
        self.btConfirm.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
    }
}
extension PRCreateRequest: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
            self?.didSelectClear?(indexPath)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.listImage[safe: indexPath.row] else { return }
        
        if model.type == .addNew {
            self.didSelectAdd?()
        } else {
//            self.didSelectOpen?(indexPath)
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
                self.didSelectOpen?(photosViewController)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:80, height: 80)
    }
}
extension PRCreateRequest: AXPhotosViewControllerDelegate {
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              willUpdate overlayView: AXOverlayView,
                              for photo: AXPhotoProtocol,
                              at index: Int,
                              totalNumberOfPhotos: Int) {
        self.currentIndexAXPhoto = index
    }
}
