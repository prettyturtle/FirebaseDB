//
//  CollectionType.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/22.
//

import Foundation

enum CollectionType: String {
    case upload = "UploadedItems"
    
    var name: String { self.rawValue }
}
