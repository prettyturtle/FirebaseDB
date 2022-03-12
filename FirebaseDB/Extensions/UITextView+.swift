//
//  UITextView+.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import UIKit

extension UITextView {
    func defaultStyle() {
        self.font = .systemFont(ofSize: 14.0, weight: .regular)
        self.heightAnchor.constraint(equalToConstant: 96.0).isActive = true
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.layer.borderColor = UIColor.separator.cgColor
        self.layer.borderWidth = 0.3
        self.layer.cornerRadius = 4.0
    }
}
