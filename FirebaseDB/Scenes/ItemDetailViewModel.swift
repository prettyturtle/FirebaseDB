//
//  ItemDetailViewModel.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/16.
//

import UIKit
import RxSwift

class ItemDetailViewModel {
    
    let disposeBag = DisposeBag()
    
    let didTapModifyButton = PublishSubject<Item>()
    
    init() {
        didTapModifyButton
            .subscribe(onNext: {
                print($0)
                // Item Modify
            })
            .disposed(by: disposeBag)
    }
}

