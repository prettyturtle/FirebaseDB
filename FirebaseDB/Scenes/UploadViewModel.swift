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
    let didTapUploadBarButton = PublishRelay<(UploadMode, Item?)>()
    
    init() {
        // New Upload
        didTapUploadBarButton
            .filter { $0.0 == .new }
            .withLatestFrom(itemInfoInput)
            .map { Item(name: $0, price: $1, count: $2, description: $3) }
            .subscribe(onNext: { [weak self] item in
                self?.FIRManager.uploadItem(item: item)
            })
            .disposed(by: disposeBag)
        
        // Modify Upload
        didTapUploadBarButton
            .filter { $0.0 == .modify }
            .compactMap { $0.1 }
            .map { (id: $0.id, itemInfo: try self.itemInfoInput.value()) }
            .subscribe(onNext: { [weak self] newItem in
                self?.FIRManager.updateItem(
                    id: newItem.id,
                    name: newItem.itemInfo.name,
                    price: newItem.itemInfo.price,
                    count: newItem.itemInfo.count,
                    description: newItem.itemInfo.description
                )
            })
            .disposed(by: disposeBag)
    }
}
