//
//  ItemDetailViewController.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ItemDetailViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let itemDetailViewModel = ItemDetailViewModel()
    
    let item: Item
    
    private let itemImageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let countLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let modifyButton = UIBarButtonItem()
    
    init(item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupLayout()
        setupAttribute()
        bind(viewModel: itemDetailViewModel)
    }
    func bind(viewModel: ItemDetailViewModel) {
        modifyButton.rx.tap
            .compactMap { [weak self] _ in self?.item }
            .bind(to: viewModel.didTapModifyButton)
            .disposed(by: disposeBag)
    }
}

private extension ItemDetailViewController {
    func setupNavigationItem() {
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        modifyButton.image = UIImage(systemName: "square.and.pencil")
        navigationItem.rightBarButtonItem = modifyButton
    }
    
    func setupAttribute() {
        view.backgroundColor = .systemBackground
        
        title = item.name
        itemImageView.backgroundColor = .separator
        nameLabel.text = item.name
        priceLabel.text = item.price.decimal + "원"
        countLabel.text = "\(item.count)개"
        descriptionLabel.text = item.description
    }
    func setupLayout() {
        [
            itemImageView,
            nameLabel,
            priceLabel,
            countLabel,
            descriptionLabel
        ].forEach { view.addSubview($0) }
        
        let commonInset = 16.0
        
        itemImageView.snp.makeConstraints {
            $0.size.equalTo(commonInset*8)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(commonInset)
            $0.centerX.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(itemImageView.snp.bottom).offset(commonInset)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(commonInset)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(commonInset)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(commonInset)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
    }
}
