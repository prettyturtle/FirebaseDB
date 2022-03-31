//
//  ItemListTableViewCell.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/15.
//

import UIKit
import SnapKit
import Kingfisher

protocol ItemListTableViewCellDelegate: AnyObject {
    func didLongPress(item: Item)
}

class ItemListTableViewCell: UITableViewCell {
    
    static let identifier = "ItemListTableViewCell"
    
    private let itemImageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let countLabel = UILabel()
    private let longPressGesture = UILongPressGestureRecognizer()
    
    var item: Item?
    
    weak var delegate: ItemListTableViewCellDelegate?
    
    func setupView() {
        guard let item = item else { return }

        setupLayout()
        setupAttribute()
        
        itemImageView.kf.setImage(with: URL(string: item.imageURL))
        nameLabel.text = item.name
        priceLabel.text = item.price.decimal + "원"
        countLabel.text = "\(item.count)개"
    }
    
    private func setupAttribute() {
        itemImageView.backgroundColor = .secondarySystemBackground
        itemImageView.layer.cornerRadius = 4.0
        longPressGesture.addTarget(self, action: #selector(didLongPressCell(_:)))
        self.addGestureRecognizer(longPressGesture)
    }
    private func setupLayout() {
        [
            itemImageView,
            nameLabel,
            priceLabel,
            countLabel
        ].forEach { addSubview($0) }
        
        let commonInset = 16.0
        
        itemImageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(commonInset)
            $0.width.equalTo(itemImageView.snp.height)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(itemImageView.snp.trailing).offset(commonInset)
            $0.top.equalTo(itemImageView.snp.top)
            $0.trailing.equalToSuperview().inset(commonInset)
        }
        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.top.equalTo(nameLabel.snp.bottom).offset(commonInset/2)
            $0.trailing.equalToSuperview().inset(commonInset)
        }
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.top.equalTo(priceLabel.snp.bottom).offset(commonInset)
            $0.trailing.equalToSuperview().inset(commonInset)
        }
        
    }
}

// MARK: - @objc func
extension ItemListTableViewCell {
    @objc func didLongPressCell(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let item = item else { return }
        delegate?.didLongPress(item: item)
    }
}
