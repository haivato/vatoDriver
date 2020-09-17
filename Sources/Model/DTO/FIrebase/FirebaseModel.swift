//  File name   : FirebaseModel.swift
//
//  Author      : Futa Corp
//  Created date: 2/22/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FirebaseFirestore

enum FirebaseModel {
}

struct DocumentChangeModel {
    var documentsDelete: [QueryDocumentSnapshot]?
    var documentsAdd: [QueryDocumentSnapshot]?
    var documentsChange: [QueryDocumentSnapshot]?
    
    init(values: CollectionValuesChanges) {
        documentsDelete = values[.removed]
        documentsAdd = values[.added]
        documentsChange = values[.modified]
    }
}

