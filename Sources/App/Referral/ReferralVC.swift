//  File name   : ReferralVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import RxCocoa
import UIKit
import SnapKit
import Kingfisher

protocol ReferralPresentableListener: class {
    var referral: Observable<ReferralResponse> { get }
    func referralMoveback()
}

final class ReferralVC: UIViewController, ReferralPresentable, ReferralViewControllable {
    struct Config {
        static let title = "Mã giới thiệu"
        static let description = "Giới thiệu VATO cho bạn bè, người thân, đồng nghiệp. Với mỗi tài khoản được nhập mã này, bạn sẽ nhận XXXX khi họ hoàn tất cuốc xe đầu tiên. Người được giới thiệu sẽ nhận được mã khuyến mãi XXXX"
        static let copy = "Sao chép"
        static let nextTitle = "Gửi lời mời!"
        static let copied = "Đã sao chép."
    }
    /// Class's public properties.
    weak var listener: ReferralPresentableListener?
    private var btnCopy: UIButton?
    private lazy var scrollView: UIScrollView = {
       let s = UIScrollView(frame: .zero)
        s.backgroundColor = .white
       return s
    }()
    private lazy var noItemView = NoItemView(imageName: "ic_referral_error", message: "Đã xảy ra lỗi, vui lòng quay lại sau.", on: view)
    private lazy var disposeBag = DisposeBag()
    private var response: ReferralResponse?
    
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
    func showError(from error: Error) {
        printDebug(error.localizedDescription)
//        let action = UIAlertAction(title: "OK", style: .cancel, handler: { _ in})
//        let alertVC = UIAlertController(title: "Lỗi", message: "Hệ thống có lỗi vui lòng thử lại sau.", preferredStyle: .alert)
//        alertVC.addAction(action)
//        self.present(alertVC, animated: true, completion: nil)
        noItemView.attach()
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

// MARK: Class's private methods
private extension ReferralVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func createView() {
        let btnNext = UIButton.create {
//            $0.applyButton(style: .default)
            $0.cornerRadius = 8
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = EurekaConfig.originNewColor
            $0.setTitle(Config.nextTitle, for: .normal)
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalTo(-16)
                    make.height.equalTo(48)
                })
        }
        
        btnNext.rx.tap.bind { [weak self] in
            self?.shareAction()
        }.disposed(by: disposeBag)
        
        scrollView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalTo(btnNext.snp.top)
            })
        }
        
        // header image view
        let screen = UIScreen.main.bounds
        let headerView = UIView.create {
            $0.backgroundColor = .clear
        }
        
        let imageView = UIImageView.create {
            $0.image = UIImage(named: "")
            } >>> headerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()
                    make.size.equalTo(CGSize(width: screen.width, height: 191))
                })
        }
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.kf.indicatorType = .activity
        let options: KingfisherOptionsInfo = [.fromMemoryCacheOrRefresh, .transition(.fade(0.3))]
        imageView.kf.setImage(with: self.response?.image?.url, placeholder: nil, options: options)
        
        // Content
        UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.numberOfLines = 0
            $0.textAlignment = .left
            $0.text = response?.description
            } >>> headerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(imageView.snp.bottom).offset(32)
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalToSuperview()
                })
        }
        
        // Sub description
        // Copy...
        let subDescriptionView = UIView.create {
            $0.backgroundColor = .clear
        }
        
        let lblSubDescription = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.textAlignment = .center
            $0.text = Config.title
            } >>> subDescriptionView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(32)
                    make.centerX.equalToSuperview()
                })
        }
        
        let codeView = UIButton.create {
            $0.isUserInteractionEnabled = false
            $0.cornerRadius = 8
            $0.setTitleColor(#colorLiteral(red: 0, green: 0.3803921569, blue: 0.2784313725, alpha: 1), for: .normal)
            $0.borderWidth = 1
            $0.borderColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2784313725, alpha: 0.4)
            $0.backgroundColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2784313725, alpha: 0.2)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            $0.setTitle(response?.code, for: .normal)
            } >>> subDescriptionView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(lblSubDescription.snp.bottom).offset(8)
                    make.centerX.equalToSuperview()
                    make.size.equalTo(CGSize(width: 180, height: 40))
                })
        }
        
        let btnCopy = UIButton.create {
            $0.setTitleColor(Color.orange, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.setTitle(Config.copy, for: .normal)
            } >>> subDescriptionView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(codeView.snp.bottom).offset(24)
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview()
                })
        }
        self.btnCopy = btnCopy
        btnCopy.rx.tap.bind { [weak self] in
            self?.copyAction()
        }.disposed(by: disposeBag)
        
        // Stack view
        UIStackView(arrangedSubviews: [headerView, subDescriptionView]) >>> scrollView >>> {
            $0.axis = .vertical
            $0.distribution = .fillProportionally
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.width.equalTo(screen.width)
                make.bottom.equalToSuperview()
            })
        }
    }
    
    private func visualize() {
        // todo: Visualize view's here.
//        let navigationBar = self.navigationController?.navigationBar
//        navigationBar?.barTintColor = Color.orange
//        navigationBar?.isTranslucent = false
//        navigationBar?.tintColor = .white
//        navigationBar?.titleTextAttributes = [.foregroundColor : UIColor.white]
//        navigationBar?.shadowImage = UIImage()
//
//        if #available(iOS 12, *) {
//        } else {
//            navigationBar?.subviews.flatMap { $0.subviews }.filter{ $0 is UIImageView }.forEach({
//                $0.isHidden = true
//            })
//        }
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(.alwaysOriginal)
        let leftBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = leftBarItem
        leftBarItem.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            
            wSelf.listener?.referralMoveback()
        }.disposed(by: disposeBag)
        
        UIApplication.setStatusBar(using: .lightContent)
        self.view.backgroundColor = .white
        self.title = Config.title
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.listener?.referral.bind(onNext: { [weak self] in
            self?.response = $0
            self?.createView()
        }).disposed(by: disposeBag)
    }
}

extension ReferralVC {
    func shareAction() {
        guard let response = self.response else {
            return
        }
        
        var items: [Any] = []
        let message = "\(response.shareText ?? "") " + "\(response.shareLink?.absoluteString ?? "")"
        items.addOptional(message)
//        items.addOptional(response.shareLink)
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { [weak self]type, complete, i, error in
            guard complete, let wSelf = self else {
                return
            }
            
            if case .some(let name) = type?.rawValue, name.lowercased().contains("copy") {
                wSelf.copyAction()
            } else {
                printDebug("Complete")
            }
        }
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func copyAction() {
        guard let btnCopy = self.btnCopy else {
            return
        }
        
        UIPasteboard.general.string = self.response?.code
        Toast.show(using: Config.copied, on: scrollView, layout: {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(btnCopy.snp.bottom).offset(5)
                make.centerX.equalTo(btnCopy.snp.centerX)
            })
        }).bind {
            printDebug("Complete")
        }.disposed(by: disposeBag)
    }
}
