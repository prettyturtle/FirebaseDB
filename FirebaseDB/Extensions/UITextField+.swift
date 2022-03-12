//
//  UITextField+.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import UIKit

extension UITextField {
    enum Style {
        case name
        case price
    }
    func defaultStyle(_ style: Style) {
        self.borderStyle = .roundedRect
        self.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        self.font = .systemFont(ofSize: 14.0, weight: .regular)
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        
        switch style {
        case .name:
            self.placeholder = "상품명을 입력하세요."
        case .price:
            self.placeholder = "가격을 입력하세요."
            self.keyboardType = .numberPad
        }
    }
}
