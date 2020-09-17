//
//  NoteDeliveryModel.swift
//  Vato
//
//  Created by THAI LE QUANG on 8/19/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

struct NoteDeliveryModel: CustomStringConvertible {
    var note: String?
    var option: String?

    var description: String {
        if option == nil {
            return "\(note ?? "")"
        }
        
        return "\(note ?? "") [\(option ?? "")]".trim()
    }
}
