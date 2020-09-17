//  File name   : ChatVC.swift
//
//  Author      : Dung Vu
//  Created date: 1/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import Kingfisher
import FwiCoreRX


fileprivate class ObjectKeyBoard: KeyboardAnimationProtocol {
    lazy var disposeBag: DisposeBag = DisposeBag()
    weak var containerView: UIView?
    
    init(with containerView: UIView?) {
        self.containerView = containerView
    }
}

protocol ChatPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var chatStream: ChatStreamImpl { get }
    var currentUser: Observable<FCDriver>{ get }
    func sendMessage(_ message: String)
    func chatMoveBack()
    
}


// MARK: Controller
final class ChatVC: UIViewController, ChatPresentable, ChatViewControllable, KeyboardAnimationProtocol {
    struct Config {
        static let wAvatar: CGFloat = 59
        static let paddingAvatar: CGFloat = -30
        static let sizeArrow: CGSize = CGSize(width: 20, height: 8)
    }
    private var source: [ChatMessageProtocol] = []
    /// Class's public properties.
    weak var listener: ChatPresentableListener?
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero)
        t.separatorColor = .clear
        return t
    }()
    
    private lazy var containerInputView: UIView = createInputView()
    private lazy var handlerKeyboardInput: ObjectKeyBoard = ObjectKeyBoard(with: containerInputView)
    private (set) lazy var disposeBag: DisposeBag = DisposeBag()
    private var currentUser: UserProtocol?
    var containerView: UIView? { return nil }
    private var task: TaskExcuteProtocol?
    
    private lazy var chatInput: InputAutoResizeView = {
        let input = InputAutoResizeView(frame: .zero)
        input.font = UIFont.systemFont(ofSize: 17)
        input.placeholder = "Nhập tin nhắn"
        input.cornerRadius = 18
        return input
    }()
    
    private lazy var containerChat: UIView = {
        let v = UIView.create({
            $0.backgroundColor = .clear
        })
        
        return v
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let i = UIImageView(frame: .zero)
        return i
    }()

    // MARK: View's lifecycle
    
    private func createInputView() -> UIView {
        let v = UIView.create {
            $0.backgroundColor = .white
        }
        
        UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
            } >>> v >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.height.equalTo(1)
            })
        }
        
        let btnSendChat = UIButton.create {
            $0.backgroundColor = Color.orange
            $0.setImage(UIImage(named: "chats"), for: .normal)
            $0.cornerRadius = 25
            } >>> v >>> {
                $0.snp.makeConstraints({ (make) in
                    make.size.equalTo(CGSize(width: 50, height: 50))
                    make.centerY.equalToSuperview().offset(-2).priority(.low)
                    make.right.equalTo(-10)
                })
        }
        
        btnSendChat.rx.tap.bind { [unowned self] in
            self.sendMessage()
        }.disposed(by: disposeBag)
        
        chatInput >>> v >>> {
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(btnSendChat.snp.left).offset(-10)
                make.left.equalTo(15)
                make.bottom.equalTo(-25)
                make.top.equalTo(10).priority(.medium)
            })
        }
        
        return v
    }
    
    func sendMessage() {
        guard let m = self.chatInput.text, m.count > 0 else {
            return
        }
        defer {
            chatInput.text = ""
        }
        
        listener?.sendMessage(m)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        animateShow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    /// Class's private properties.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }
        
        let p = point.location(in: self.view)
        guard self.containerChat.frame.contains(p) == false else {
            return
        }
        self.listener?.chatMoveBack()
    }
    
    private func animateShow() {
        let transformImgView = CGAffineTransform(translationX: 0, y: 1000).scaledBy(x: 0.1, y: 0.1)
        let transformContainer = CGAffineTransform(translationX: 0, y: -500).scaledBy(x: 0.1, y: 0.1)
        self.avatarImageView.transform = transformImgView
        self.containerChat.transform = transformContainer

        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [.calculationModeLinear, .calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                self.avatarImageView.transform = .identity
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3, animations: {
                self.containerChat.transform = .identity
            })
        }) { (_) in }
    }
    
    func runAnimate(by keyboarInfor: KeyboardInfo?) {
        guard let i = keyboarInfor else {
            return
        }
        let h = i.height
        let d = i.duration
        
        UIView.animate(withDuration: d, animations: { [unowned self] in
            self.tableView.contentInset = UIEdgeInsets(top: h, left: 0, bottom: 0, right: 0)
        }) { [weak self] (complete) in
            guard let wSelf = self else { return }
            guard complete, wSelf.source.count > 0 else {
                return
            }
            wSelf.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
        }
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

// MARK: View's event handlers
extension ChatVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Class's public methods
extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    private func setupDisplay(for cell: PTSMessagingCell, at index: IndexPath) {
        let item = source[index.item]
        cell.transform = CGAffineTransform(rotationAngle: .pi)
        assert(self.currentUser?.userID != nil, "Check !!!!")
        let userId = "\(self.currentUser?.userID ?? 0)"
        let date = Date(timeIntervalSince1970: TimeInterval(item.time) / 1000)
        let m = date.string(from: "HH:mm")
        let color: UIColor
        if item.sender?.contains("d") == true && item.sender?.contains(userId) == true {
            color = .white
            cell.sent = true
            cell.avatarImageView?.image = UIImage(named: "person1")
            cell.timeLabel?.text = m
        } else {
            color = .black
            cell.sent = false
            let currentDriver = self.listener?.chatStream.currentDriver
            let current = self.listener?.chatStream.currentDriver?.avatarUrl
            let task = cell.avatarImageView.setImage(from: current, placeholder: UIImage(named: "avatar-holder"), size: CGSize(width: Config.wAvatar , height: Config.wAvatar))
            cell.avatarImageView.contentMode = .scaleAspectFill
            cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)).take(1).bind { (_) in
                task?.cancel()
            }.disposed(by: disposeBag)
            
            cell.timeLabel?.text = "\(currentDriver?.fullName ?? ""), \(m)"
        }
        
        cell.messageLabel?.textColor = color
        cell.messageLabel?.text = item.message
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PTSMessagingCell? = tableView.dequeueReusableCell(withIdentifier: PTSMessagingCell.identifier) as? PTSMessagingCell
        if cell == nil {
            cell = PTSMessagingCell(messagingCellWithReuseIdentifier: PTSMessagingCell.identifier)
            cell?.selectionStyle = .none
        }
        self.setupDisplay(for: cell!, at: indexPath)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = source[indexPath.item]
        let m = item.message ?? ""
        let s = PTSMessagingCell.messageSize(m)
        return s.height + 2 * PTSMessagingCell.textMarginVertical() + 40
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ChatVC {
    func setupKeyboardAnimation() {
        let eShowKeyBoard = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map({ KeyboardInfo($0) })
        let eHideKeyBoard = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map({ KeyboardInfo($0) })
        
        Observable.merge([eShowKeyBoard, eHideKeyBoard]).bind { [weak self] in
            self?.runAnimate(by: $0)
        }.disposed(by: disposeBag)
    }
}


// MARK: Class's private methods
private extension ChatVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = Color.black40
        avatarImageView >>> view >>> {
            $0.borderWidth = 1
            $0.borderColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
            $0.layer.cornerRadius = Config.wAvatar / 2
            $0.clipsToBounds = true
            
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(24)
                make.right.equalTo(Config.paddingAvatar)
                make.size.equalTo(CGSize(width: Config.wAvatar , height: Config.wAvatar))
            })
        }
        
        containerChat >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.top.equalTo(avatarImageView.snp.bottom)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
        
        
        let arrow = ArrowView(by: .white) >>> containerChat >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(2)
                make.size.equalTo(Config.sizeArrow)
                make.right.equalTo(Config.paddingAvatar - Config.wAvatar / 2 + Config.sizeArrow.width / 2)
            })
        }
        
        UIView.create {
            $0.backgroundColor = .white
            $0.cornerRadius = 5
            } >>> containerChat >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(arrow.snp.bottom)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.bottom.equalToSuperview()
                })
        }
        
        containerInputView >>> containerChat >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.greaterThanOrEqualTo(71.5)
            })
        }
        
        self.tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        self.tableView >>> containerChat >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(arrow.snp.bottom).offset(5)
                make.bottom.equalTo(containerInputView.snp.top).priority(.medium)
            })
        }
        
        containerChat.bringSubviewToFront(containerInputView)
        
        self.tableView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.handlerKeyboardInput.setupKeyboardAnimation()
        self.setupKeyboardAnimation()
        
        self.listener?.currentUser.take(1).bind(onNext: { [weak self](u) in
            self?.currentUser = u.user
            self?.setupSource()
        }).disposed(by: disposeBag)
    }
    
    
    private func setupSource() {
        let current = self.listener?.chatStream.currentDriver?.avatarUrl
        avatarImageView.contentMode = .scaleAspectFill
        task = avatarImageView.setImage(from: current, placeholder: UIImage(named: "avatar-holder"), size: CGSize(width: Config.wAvatar , height: Config.wAvatar))
        self.listener?.chatStream.currentList.bind(onNext: { [weak self](list) in
            defer {
                self?.listener?.chatStream.resetChatBadges()
            }
            guard let wSelf = self else {
                return
            }
            let previous = wSelf.source.count
            let next = list.count
            wSelf.source = list
            defer {
                if next > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        wSelf.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
                    })
                }
            }
            
            if previous == 0 {
                wSelf.tableView.reloadData()
            } else {
                guard next > previous else {
                    wSelf.tableView.reloadData()
                    return
                }
                let range = next - previous
                wSelf.tableView.beginUpdates()
                defer { wSelf.tableView.endUpdates() }
                let indexs = (0..<range).map { IndexPath(item: $0, section: 0) }
                wSelf.tableView.insertRows(at: indexs, with: .fade)
            }
        }).disposed(by: disposeBag)
    }
}
