//
//  Int+.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/15.
//

import Foundation

extension Int {
    var decimal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
