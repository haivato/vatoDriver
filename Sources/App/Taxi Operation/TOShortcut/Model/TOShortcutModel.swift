//
//  File.swift
//  Vato
//
//  Created by khoi tran on 2/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

struct TOShortutModel: TOShortcutCellDisplay {
    var isNew: Bool?
    var badgeNumber: Int?
    var name: String?
    var description: String?
    var icon: UIImage?
    var cellType: TOShortcutCellType
    var type: TOShortCutType
}
