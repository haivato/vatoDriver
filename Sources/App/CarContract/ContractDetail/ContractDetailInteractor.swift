//  File name   : ContractDetailInteractor.swift
//
//  Author      : Phan Hai
//  Created date: 28/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import CoreLocation
import RxCocoa
import FwiCore
import FwiCoreRX
import VatoNetwork
import Alamofire

protocol ContractDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func moveToChat(item: OrderContract)
    func showAlertError(text: String)
    func routeToReceipt(item: OrderContract)
}

protocol ContractDetailPresentable: Presentable {
    var listener: ContractDetailPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ContractDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func backCarContract()
    func routeToHome()
}

final class ContractDetailInteractor: PresentableInteractor<ContractDetailPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: ContractDetailRouting?
    weak var listener: ContractDetailListener?
    private var item: OrderContract
    private var chatStream: ChatStreamImpl
    
    /// Class's constructor.
    init(presenter: ContractDetailPresentable, item: OrderContract, chatStream: ChatStreamImpl) {
        self.item = item
        self.chatStream = chatStream
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        mItem = self.item
        setupRX()
        loadChat()
        // todo: Implement business logic here.
    }
    var options: OptionContract?
    @Replay(queue: MainScheduler.asyncInstance) private var mItem: OrderContract
    @Replay(queue: MainScheduler.asyncInstance) private var mTextError: String
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
}

// MARK: ContractDetailInteractable's members
extension ContractDetailInteractor: ContractDetailInteractable {
    func routeToHome() {
        self.listener?.routeToHome()
    }
    
    func moveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func chatMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func send(message: String) {
        
    }
    func updateStatus() {
        guard let id = item.order_id else {
            return
        }
        var stt: String = ""
        switch item.trip_status {
        case .CREATED:
            stt = TripContractStatus.DRIVER_ACCEPTED.rawValue
        case .DRIVER_ACCEPTED:
             stt = TripContractStatus.DRIVER_STARTED.rawValue
        case .DRIVER_STARTED:
            stt = TripContractStatus.DRIVER_FINISHED.rawValue
        default:
            break
        }
        let p: [String: Any] = ["trip_status": stt]
        let url = TOManageCommunication.path("/rental-car/driver/orders/\(id)/trip-status")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: p, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
            network.request(using: router,
                            decodeTo: OptionalMessageDTO<OrderContract>.self,
                            method: .post,
                            encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self] (result) in
                guard let wSelf = self else {
                    return
                }
                switch result {
                case .success(let r):
                    if r.fail == false {
                        switch wSelf.item.trip_status {
                        case .CREATED:
                            wSelf.item.trip_status = TripContractStatus.DRIVER_ACCEPTED
                        case .DRIVER_ACCEPTED:
                             wSelf.item.trip_status = TripContractStatus.DRIVER_STARTED
                        case .DRIVER_STARTED:
                            wSelf.item.trip_status = TripContractStatus.DRIVER_FINISHED
                            wSelf.router?.routeToReceipt(item: wSelf.item)
                        default:
                            break
                        }
                        wSelf.mItem = wSelf.item
                    } else {
                        wSelf.mTextError = r.message ?? ""
                    }
                case .failure(let e):
                    wSelf.mTextError = e.localizedDescription
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    
}

// MARK: ContractDetailPresentableListener's members
extension ContractDetailInteractor: ContractDetailPresentableListener {
    var itemContractDetail: Observable<OrderContract> {
        return self.$mItem
    }
    var textError: Observable<String> {
        return self.$mTextError
    }
    func moveBackHome() {
        self.listener?.backCarContract()
    }
    func moveToChat() {
        if let client = self.item.user {
            self.chatStream.update(driver: client)
        }
        self.router?.moveToChat(item: self.item)
    }
}

// MARK: Class's private methods
private extension ContractDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    func loadChat() {
         // List
         let databaseRef = Database.database().reference()
        let node = FireBaseTable.chats >>> .custom(identify: item.order_id ?? "")
         databaseRef.find(by: node, type: .value, using: {
             $0.keepSynced(true)
             return $0
         })
         .take(1)
         .map { snapshot -> [ChatMessageProtocol] in
             let childrens = snapshot.children.compactMap({ $0 as? DataSnapshot })
             let chats = try childrens.map({ try ChatMessage.create(from: $0) }).sorted(by: >)
             return chats
         }.bind { [weak self] (chats) in
            guard let wSelf = self else {
                return
            }
             wSelf.chatStream.update(listChat: chats)
             wSelf.listenNewChat(node: node)
         }.disposeOnDeactivate(interactor: self)
     }
     
     func listenNewChat(node: NodeTable) {
         // Listen new
         let databaseRef = Database.database().reference()
         databaseRef.find(by: node, type: .childAdded, using: {
             $0.keepSynced(true)
             return $0
         }).bind { [weak self] (snapshot) in
            guard let wSelf = self else {
                return
            }
             do {
                 let new = try ChatMessage.create(from: snapshot)
                 wSelf.chatStream.update(newMessage: new)
             } catch {
                 print(error.localizedDescription)
             }
         }.disposeOnDeactivate(interactor: self)
     }
}
