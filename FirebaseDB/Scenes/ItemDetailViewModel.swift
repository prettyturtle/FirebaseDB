//
//  ItemDetailViewModel.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/16.
//

import UIKit
import RxSwift
import RxCocoa

class ItemDetailViewModel {
    
    let disposeBag = DisposeBag()
    let uploadViewModel = UploadViewModel()
    
    let didTapModifyButton = PublishSubject<Item>()
    let moveToUploadViewController = PublishSubject<UploadViewController>()
    init() {
        didTapModifyButton
            .map { item in
                let uploadVC = UploadViewController()
                uploadVC.item = item
                uploadVC.uploadMode = .modify
                uploadVC.setupModifyView(item: item)
                uploadVC.bind(viewModel: self.uploadViewModel)
                return uploadVC
            }
            .bind(to: moveToUploadViewController)
            .disposed(by: disposeBag)
    }
}

