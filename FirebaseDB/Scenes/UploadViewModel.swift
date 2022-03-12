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
    let db = Firestore.firestore()
    
    let itemInfoInput = BehaviorSubject<(
        name: String,
        price: String,
        count: Int,
        description: String
    )>(value: (
        name: "",
        price: "",
        count: 1,
        description: ""
    ))
    let didTapUploadBarButton = PublishRelay<Void>()
    
    init() {
        didTapUploadBarButton
            .withLatestFrom(itemInfoInput)
            .map { Item(name: $0, price: $1, count: $2, description: $3) }
            .subscribe(onNext: {
                self.uploadItem(item: $0)
            })
            .disposed(by: disposeBag)
    }
    
    func uploadItem(item: Item) {
        let data = [
            "id": item.id,
            "name": item.name,
            "price": item.price,
            "count": item.count,
            "description": item.description
        ] as [String : Any]
        
        db.collection("UploadedItems")
            .document(item.name + "__" + item.id)
            .setData(data) { error in
                if let error = error {
                    print("UploadViewModel - uploadItem - ERROR: \(error.localizedDescription)")
                } else {
                    print("상품 업로드 성공!!!")
                }
            }
    }
}
