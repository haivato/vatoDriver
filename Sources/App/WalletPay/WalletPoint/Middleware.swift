//  File name   : Middleware.swift
//
//  Author      : Dung Vu
//  Created date: 2/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import GCDWebServer

protocol MiddlewareHandlerDelegate: AnyObject {
    func process(url: URL, block: @escaping GCDWebServerBodyReaderCompletionBlock)
}


struct Middleware {
    let webServer = GCDWebServer()
    weak var handler: MiddlewareHandlerDelegate?
    private let port: UInt
    init(handler: MiddlewareHandlerDelegate, port: UInt = 8382) {
        self.handler = handler
        self.port = port
        setup()
    }
    
    private func setup() {
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            return GCDWebServerStreamedResponse(contentType: "text/html") { (block) in
                self.handler?.process(url: request.url, block: block)
            }
        }
    }
    
    func start() -> URL? {
        do {
            try webServer.start(options: [GCDWebServerOption_Port: port,
                                          GCDWebServerOption_BindToLocalhost: true,
                                          GCDWebServerOption_BonjourName: "Vato Web" ])
            return webServer.serverURL
        } catch {
            assert(false, error.localizedDescription)
            return nil
        }
    }
    
    func stop() {
        webServer.stop()
    }
}

