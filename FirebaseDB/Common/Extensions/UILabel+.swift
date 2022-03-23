//
//  UILabel+.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import UIKit

extension UILabel {
    func fieldLabelStyle(_ style: FormStyle) {
        self.font = .systemFont(ofSize: 16.0, weight: .medium)
        self.text = style.text
    }
}
