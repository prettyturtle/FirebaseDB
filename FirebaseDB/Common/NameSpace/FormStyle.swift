//
//  FormStyle.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/23.
//

import Foundation

enum FormStyle: String {
    case name = "상품명"
    case price = "가격"
    case count = "수량"
    case description = "상품설명"
    
    var text: String { self.rawValue }
}
