//
//  UITextField+.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import UIKit

extension UITextField {
    func defaultStyle(_ style: FormStyle) {
        self.borderStyle = .roundedRect
        self.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        self.font = .systemFont(ofSize: 14.0, weight: .regular)
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.placeholder = "\(style.text)을 입력하세요."
        if style == .price {
            self.keyboardType = .numberPad
        }
    }
}
