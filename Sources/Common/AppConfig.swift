//  File name   : AppConfig.swift
//
//  Author      : Dung Vu
//  Created date: 11/14/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore

struct AppConfig: Codable, PlistProtocol {
    static let `default` = AppConfig.load()
    
    enum PlistFile {
        case config
        case main
        
        var name: String {
            switch self {
            case .config:
                return "AppConfig"
            case .main:
                return "Info"
            }
        }
    }
    
    struct AppInfor: Codable, PlistProtocol {
        var bundleIdentifier: String?
        var version: String?
        var appName: String?
        var build: String?
        
        enum CodingKeys: String, CodingKey {
            case bundleIdentifier = "CFBundleIdentifier"
            case version = "CFBundleShortVersionString"
            case appName = "CFBundleName"
            case build = "CFBundleVersion"
        }
    }
    
    
    enum VatoCustomer: Int, Codable {
        case client = 0
        case driver
        
        var isDriver: Bool {
            return self == VatoCustomer.driver
        }
    }
    
    let customer: VatoCustomer
    var appInfor: AppInfor?
    
    static func load() -> AppConfig {
        guard var result: AppConfig = tryNotThrow({ try AppConfig.load(PlistFile.config.name) }, default: nil) else {
            fatalError("Check Resource")
        }
        let appInfor: AppInfor? = tryNotThrow({ try AppInfor.load(PlistFile.main.name) }, default: nil)
        result.appInfor = appInfor
        return result
    }
}

