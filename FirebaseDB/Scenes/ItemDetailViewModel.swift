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
    
    let didTapModifyButton = PublishSubject<Item>()
    let moveToUploadViewController = PublishSubject<UploadViewController>()
    init() {
        didTapModifyButton
            .map { item in
                let uploadVC = UploadViewController()
                uploadVC.item = item
                uploadVC.uploadMode = .modify
                return uploadVC
            }
            .bind(to: moveToUploadViewController)
            .disposed(by: disposeBag)
    }
}

