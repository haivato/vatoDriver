//  File name   : FeedbackCancelResonVC.swift
//
//  Author      : vato.
//  Created date: 2/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCoreRX
import Eureka

protocol FeedbackCancelResonPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var modelsObser: Observable<[CancelModel]> { get }
    func requestListReason()
    func cancelReasonMoveBack()
    func submit(index: Int)
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var otherReason: String? { get set }
    var tripId: String { get }
    var type: FeedbackCancelResonType { get }
    var groupServiceType: GroupServiceType { get }
    func didSelectAction(action: FeedbackCancelAction)
    func removePhoto(index: Int)
    var imagesObser: Observable<[UIImage]> { get }
}

final class FeedbackCancelResonVC: FormViewController, FeedbackCancelResonPresentable, FeedbackCancelResonViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: FeedbackCancelResonPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        if isFirst == true {
            super.viewWillAppear(animated)
        }
        localize()
        isFirst = false
    }

    /// Class's private properties.
//    @IBOutlet private weak var tableView: UITableView!
    internal lazy var disposeBag = DisposeBag()
    private var data: [CancelModel] = []
    private var submitBtn: UIButton?
    private var backBtn: UIButton?
    private var viewBottom: UIStackView?
    private var isLoading = false
    private var isFirst = true
}

// MARK: View's event handlers
extension FeedbackCancelResonVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension FeedbackCancelResonVC {
    func showError(eror: Error) {
          AlertVC.showError(for: self, error: eror as NSError)
      }
   
    func showAlert(message: String) {
        AlertVC.showMessageAlert(for: self, title: "Lưu ý", message: message, actionButton1: "Hủy", actionButton2: nil, handler2:nil)
    }
}

// MARK: Class's private methods
private extension FeedbackCancelResonVC {
    private func localize() {
        // todo: Localize view's here.
        title = self.listener?.type.titleCancel()
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        tableView.backgroundColor = self.listener?.type.backgroundColor() ?? #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        tableView.separatorColor = .clear
        let backButton = UIButton.create {
            $0.setBackground(using: .white, state: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.setTitle("QUAY LẠI", for: .normal)
        }
        backBtn = backButton
        
        let button = UIButton.create {
            $0.setBackground(using: Color.orange, state: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.setTitle("XÁC NHẬN", for: .normal)
        }
        
        button.isEnabled = false
        submitBtn = button
        
        let stackView = UIStackView(arrangedSubviews: [backButton, button])
        stackView >>> view >>> {
            $0.distribution = .fillEqually
            $0.spacing = 20
            $0.axis = .horizontal
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-40)
                make.height.equalTo(48)
            })
        }
        viewBottom = stackView

        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalTo(button.snp.top).offset(-10)
            })
        }
        
        let labelAppVersion = UILabel(frame: .zero)
        labelAppVersion >>> view >>> {
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.textAlignment = .center
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.top.equalTo(stackView.snp_bottomMargin).offset(5)
                make.height.equalTo(20)
            })
        }
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        labelAppVersion.text = "\(UserManager.shared.getUserId() ?? 0) | \(appVersion) | \(listener?.tripId ?? "")"
        
    }
    
    private func setupRX() {
        listener?.modelsObser.bind(onNext: { [weak self] (data) in
            guard let wSelf = self else { return }
            wSelf.loadData(data: data)
        }).disposed(by: disposeBag)
        
        listener?.imagesObser.bind(onNext: { [weak self] (images) in
            guard let imageCell = self?.form.rowBy(tag: FoodReceivePackageCellType.image.rawValue) as? RowDetailGeneric<RequestQuickSupportImageCell> else { return }
            imageCell.cell.reloadData(_images: images)
        }).disposed(by: disposeBag)
        
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map (KeyboardInfo.init)
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map (KeyboardInfo.init)
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] d in
            UIView.animate(withDuration: d.duration, animations: {
                self?.viewBottom?.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(-(d.height + 20))
                })
                self?.view.layoutIfNeeded()
            }, completion: { c in
                guard d.height > 0 else {
                    return
                }
                let idx = IndexPath(item: (self?.form.allRows.count ?? 1) - 1, section: 0)
                self?.tableView.scrollToRow(at: idx, at: .bottom, animated: true)
            })
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            
            if let cell = wSelf.tableView.cellForRow(at: indexPath) as? NoteTableViewCell {
                let text = cell.textView.text ?? ""
                cell.textView.becomeFirstResponder()
                wSelf.submitBtn?.isEnabled = !(text.trim()).isEmpty
            } else {
                wSelf.submitBtn?.isEnabled = true
            }
        }.disposed(by: disposeBag)
        
        submitBtn?.rx.tap.bind(onNext: { [weak self] (_) in
            guard self?.isLoading == false else { return }
            if let index = self?.tableView.indexPathForSelectedRow?.row {
                self?.listener?.submit(index: index)
            }
        }).disposed(by: disposeBag)
        
        listener?.eLoadingObser.bind(onNext: { [weak self] (value) in
            self?.isLoading = value.0
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        backBtn?.rx.tap.bind(onNext: { [weak self] (_) in
            self?.listener?.cancelReasonMoveBack()
        }).disposed(by: disposeBag)
    }
    
    func loadData(data: [CancelModel]) {
        UIView.performWithoutAnimation {
            self.form.removeAll()
        }
        let section = Section() { (s) in
            s.tag = "InfoPackage"
            // header
            var header = HeaderFooterView<UIView>(.callback {
                let v = UIView()
                        
                let lblWarning = UILabel()
                lblWarning >>> v >>> {
                    $0.numberOfLines = 0
                    $0.textColor =  #colorLiteral(red: 0.9764705882, green: 0.8352941176, blue: 0.2980392157, alpha: 1)
                    $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
                    $0.text = "VATO sẽ hậu kiểm chuyến đi. Nếu bác tài chọn lý do không đúng sự thật sẽ ảnh hưởng đến ưu tiên nhận chuyến."
                    $0.snp.makeConstraints {
                        $0.left.equalTo(34)
                        $0.right.equalTo(10)
                    }
                }
                
                let imgViewWarning = UIImageView()
                imgViewWarning >>> v >>> {
                    $0.contentMode = .scaleAspectFit
                    $0.image = UIImage.init(named: "ic_warning")
                    
                    $0.snp.makeConstraints {
                        $0.height.equalTo(24)
                        $0.width.equalTo(24)
                        $0.left.equalTo(5)
                        $0.centerY.equalTo(lblWarning.snp.centerY)
                    }
                }

                let label = UILabel()
                label >>> v >>> {
                    $0.numberOfLines = 2
                    $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
                    $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                    $0.text = self.listener?.type.title()
                    $0.snp.makeConstraints {
                        $0.left.equalTo(10)
                        $0.top.equalTo(lblWarning.snp.bottom).offset(10)
                    }
                }

                return v
                })
            header.height = { 100 }
            
            
            s.header = header
        }
        
        data.forEach { model in
            if model.id == -1 {
                section <<< NoteCellEureka.init(FoodReceivePackageCellType.note.rawValue, { (row) in
                    row.cell.backgroundColor = self.listener?.type.backgroundColor() ?? #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
                    row.cell.lbTitle.text = model.description
                    row.cell.textView.rx.text.bind { (value) in
                        let text = value ?? ""
                        self.submitBtn?.isEnabled = !(text.trim()).isEmpty
                        self.listener?.otherReason = value
                    }.disposed(by: self.disposeBag)
                })
            } else {
                section <<< ResonCellEureka(){ (row) in
                    row.cell.backgroundColor = self.listener?.type.backgroundColor() ?? #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
                    row.cell.titleLabel.text = model.description
                    row.cell.subTitleLabel.text = model.extensionName ?? ""
                }
            }
        }
        
        if listener?.type.showPhotos == true || listener?.groupServiceType == .express {
            section <<< RowDetailGeneric<RequestQuickSupportImageCell>.init(FoodReceivePackageCellType.image.rawValue, { [weak self] (row) in
                row.cell.selectionStyle = .none
                row.cell.update(title: "Chụp ảnh xác nhận giao hàng thất bại(Tối đa 3 hình)")
                row.cell.reloadData(_images: [])
                row.cell.didSelectAdd = { [weak self] in self?.listener?.didSelectAction(action: .openCamera) }
                row.cell.didSelectClear = { [weak self] indexPath in self?.listener?.removePhoto(index: indexPath.row) }
            })
        }
        
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    func showActionSheetPhoto() {
        let optionMenuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addAction = UIAlertAction(title: "Mở Camera", style: .default, handler:{ [weak self] (_) in
            self?.listener?.didSelectAction(action: .openCamera)
        })
        let saveAction = UIAlertAction(title: "Chọn Hình từ Photo", style: .default, handler:{ [weak self] (_) in
            self?.listener?.didSelectAction(action: .openPhoto)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenuController.addAction(addAction)
        optionMenuController.addAction(saveAction)
        optionMenuController.addAction(cancelAction)
        
        self.present(optionMenuController, animated: true, completion: nil)
    }
    
}

extension FeedbackCancelResonVC {
}
