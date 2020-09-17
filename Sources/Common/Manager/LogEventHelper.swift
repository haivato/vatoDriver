//  File name   : TrackingHelper.swift
//
//  Author      : Dung Vu
//  Created date: 12/20/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FirebaseAnalytics


/*
 RULE Log:
 Parttern: module_key_ios
 Include:
    1> module: name module implement
    2> key: Value want to track, camel case . Ex: buy_ticket_fail
 */

enum Feature: String {
    case experess
}

struct LogEventHelper {
    private static let queue = DispatchQueue.global(qos: .background)
    
    static func log(key: String,
                    params: [String: Any]?,
                    line: Int = #line,
                    function: String = #function)
    {
        assert(!key.isEmpty, "Key is not empty")
        queue.async {
            var params = params ?? [:]
            params["line"] = line
            params["function"] = function
            appInfo(&params)
            Analytics.logEvent(key, parameters: params)
    }
    }
    
    private static func appInfo(_ params: inout [String: Any]) {
//        let appInfo = AppConfig.default.appInfor
//        params["appName"] = appInfo?.appName
//        params["appVersion"] = appInfo?.version
//        params["appBundle"] = appInfo?.bundleIdentifier
//        params["date_created"] = Date().string(from: "yyyy/MM/dddd")
    }
    
    static func log<T: Encodable>(key: String,
                       value: T,
                       params: [String: Any]?,
                    line: Int = #line,
                    function: String = #function)
    {
        assert(!key.isEmpty, "Key is not empty")
        queue.async {
            var params = params ?? [:]
            let encode = JSONEncoder()
            do {
                let data = try encode.encode(value)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                params["responseJSON"] = json
            } catch {
                params["errorJSON"] = error.localizedDescription
            }
            
            params["line"] = line
            params["function"] = function
            appInfo(&params)
            Analytics.logEvent(key, parameters: params)
        }
    }
}


