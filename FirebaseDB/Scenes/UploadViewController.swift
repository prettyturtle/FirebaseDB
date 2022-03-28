//
//  UploadViewController.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class UploadViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    var item: Item?
    var uploadMode: UploadMode = .new
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let uploadBarButton = UIBarButtonItem()
    private let itemImageSelectButton = UIButton()
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    private let priceLabel = UILabel()
    private let priceTextField = UITextField()
    private let wonLabel = UILabel()
    private let countLabel = UILabel()
    private let currentCountLabel = UILabel()
    private let countStepper = UIStepper()
    private let descriptionLabel = UILabel()
    private let descriptionTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAttribute()
        setupLayout()
    }
    
    func bind(viewModel: UploadViewModel) {
        Observable
            .combineLatest(nameTextField.rx.text.orEmpty, priceTextField.rx.text.orEmpty, countStepper.rx.value, descriptionTextView.rx.text.orEmpty)
            .map { (name: $0, price: Int($1) ?? 0, count: Int($2), description: $3) }
            .bind(to: viewModel.itemInfoInput)
            .disposed(by: disposeBag)
        countStepper.rx.value.changed
            .map { String(Int($0)) + "개" }
            .bind(to: currentCountLabel.rx.text)
            .disposed(by: disposeBag)
        uploadBarButton.rx.tap
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .compactMap { [weak self] _ in self?.uploadMode }
            .map { [weak self] mode in (mode, self?.item)}
            .bind(to: viewModel.didTapUploadBarButton)
            .disposed(by: disposeBag)
        itemImageSelectButton.rx.tap
            .bind(to: viewModel.didTapImageSelectButton)
            .disposed(by: disposeBag)
        
        viewModel.presentToImagePicker
            .subscribe(onNext: {
                self.present($0, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedImage
            .observe(on: MainScheduler.instance)
            .map { [weak self] image in
                self?.itemImageSelectButton.setTitle("", for: .normal)
                return image
            }
            .compactMap { $0 }
            .observe(on: ConcurrentMainScheduler.instance)
            .bind(to: itemImageSelectButton.rx.backgroundImage())
            .disposed(by: disposeBag)
    }
    func setupModifyView(item: Item) {
        itemImageSelectButton.kf.setBackgroundImage(with: URL(string: item.imageURL), for: .normal)
        nameTextField.text = item.name
        priceTextField.text = "\(item.price)"
        countStepper.value = Double(item.count)
        currentCountLabel.text = "\(item.count)개"
        descriptionTextView.text = item.description
    }
}

private extension UploadViewController {
    func setupAttribute() {
        setupNavigationBar()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        nameLabel.fieldLabelStyle(.name)
        priceLabel.fieldLabelStyle(.price)
        wonLabel.font = .systemFont(ofSize: 14.0, weight: .regular)
        wonLabel.text = "원"
        countLabel.fieldLabelStyle(.count)
        descriptionLabel.fieldLabelStyle(.description)
        itemImageSelectButton.setTitle("사진을 선택하세요.", for: .normal)
        itemImageSelectButton.setTitleColor(.systemPink, for: .normal)
        itemImageSelectButton.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .regular)
        itemImageSelectButton.backgroundColor = .secondarySystemBackground
        itemImageSelectButton.layer.cornerRadius = 4.0
        nameTextField.defaultStyle(.name)
        priceTextField.defaultStyle(.price)
        currentCountLabel.font = .systemFont(ofSize: 14.0, weight: .regular)
        currentCountLabel.text = "1개"
        countStepper.value = 1
        countStepper.minimumValue = 1
        descriptionTextView.defaultStyle()
    }
    func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        [
            itemImageSelectButton,
            nameLabel,
            nameTextField,
            priceLabel,
            priceTextField,
            wonLabel,
            countLabel,
            currentCountLabel,
            countStepper,
            descriptionLabel,
            descriptionTextView
        ].forEach { contentView.addSubview($0) }
        
        let commonInset = 16.0
        
        itemImageSelectButton.snp.makeConstraints {
            $0.size.equalTo(commonInset*8)
            $0.top.equalToSuperview().inset(commonInset)
            $0.centerX.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(itemImageSelectButton.snp.bottom).offset(commonInset)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(commonInset/2)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(commonInset)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
        priceTextField.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(commonInset/2)
            $0.trailing.equalTo(wonLabel.snp.leading).offset(-commonInset/2)
            $0.width.equalTo(150.0)
        }
        wonLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(commonInset)
            $0.centerY.equalTo(priceTextField)
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(priceTextField.snp.bottom).offset(commonInset)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
        countStepper.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(commonInset/2)
            $0.trailing.equalToSuperview().inset(commonInset)
        }
        currentCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(countStepper)
            $0.trailing.equalTo(countStepper.snp.leading).offset(-commonInset)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(countStepper.snp.bottom).offset(commonInset)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
        }
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(commonInset/2)
            $0.leading.trailing.equalToSuperview().inset(commonInset)
            $0.bottom.equalToSuperview().inset(commonInset)
        }
    }
    func setupNavigationBar() {
        switch uploadMode {
        case .new:
            title = "상품 등록"
            uploadBarButton.title = "등록"
        case .modify:
            title = "상품 수정"
            uploadBarButton.title = "수정"
        }
        
        navigationItem.rightBarButtonItem = uploadBarButton
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
}
