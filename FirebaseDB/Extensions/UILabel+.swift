//
//  UILabel+.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import UIKit

extension UILabel {
    enum Style {
        case name
        case price
        case count
        case description
    }
    func fieldLabelStyle(_ style: Style) {
        self.font = .systemFont(ofSize: 16.0, weight: .medium)
        
        switch style {
        case .name:
            self.text = "상품명"
        case .price:
            self.text = "가격"
        case .count:
            self.text = "수량"
        case .description:
            self.text = "상품설명"
        }
    }
}
