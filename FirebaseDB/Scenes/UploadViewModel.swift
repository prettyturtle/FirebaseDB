//
//  UploadViewModel.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import Foundation
import RxSwift
import RxRelay
import Firebase

class UploadViewModel {
    let disposeBag = DisposeBag()
    let FIRManager = FirestoreManager()
    
    let itemInfoInput = BehaviorSubject<(
        name: String,
        price: Int,
        count: Int,
        description: String
    )>(value: (
        name: "",
        price: 0,
        count: 1,
        description: ""
    ))
    let didTapUploadBarButton = PublishRelay<Void>()
    
    init() {
        didTapUploadBarButton
            .withLatestFrom(itemInfoInput)
            .map { Item(name: $0, price: $1, count: $2, description: $3) }
            .subscribe(onNext: { [weak self] item in
                self?.FIRManager.uploadItem(item: item)
            })
            .disposed(by: disposeBag)
    }
}
