//  File name   : FirebaseModel+BankTransferConfig.swift
//
//  Author      : Futa Corp
//  Created date: 2/22/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

extension FirebaseModel {
    struct BankTransferConfig: Codable, ModelFromFireBaseProtocol {
        let accountName: String
        let accountNumber: String
        let bankName: String
        let bankNameFull: String
        let banner: URL?
        let content: String?
        let icon: URL?

        let recordID: UInt

        /// Codable's keymap.
        private enum CodingKeys: String, CodingKey {
            case accountName = "account_name"
            case accountNumber = "account_number"

            case bankName = "bank_name"
            case bankNameFull = "bank_name_full"
            case banner
            case content
            case icon

            case recordID = "id"
        }
    }
}
