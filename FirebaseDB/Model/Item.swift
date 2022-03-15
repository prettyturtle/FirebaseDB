//
//  Item.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import Foundation

struct Item: Codable {
    var id: String = UUID().uuidString
    let name: String
    let price: Int
    let count: Int
    let description: String
}
