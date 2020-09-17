//
//  Define.swift
//  FC
//
//  Created by vato. on 2/10/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

let defautAvatar = "https://firebasestorage.googleapis.com/v0/b/vato-2019-dev.appspot.com/o/images%2Favatar-placeholder-1.png?alt=media"
enum UserType: Int {
    case client = 1
    case driver = 2
}
enum UserRequestType: String {
    case client = "CLIENT"
    case driver = "DRIVER"
}
