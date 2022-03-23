//
//  ItemListViewModel.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/13.
//

import Foundation
import RxSwift
import RxRelay

class ItemListViewModel {
    
    let disposeBag = DisposeBag()
    let FIRManager = FirestoreManager()
    let itemDetailViewModel = ItemDetailViewModel()
    
    let itemList = BehaviorSubject<[Item]>(value: [])
    let refreshBegin = PublishRelay<Void>()
    let refreshEnd = PublishRelay<Void>()
    let selectedRow = PublishRelay<Int>()
    let moveToDetailVC = PublishSubject<Item>()
    
    init() {
        refreshBegin
            .subscribe(onNext: { [weak self] _ in
                self?.fetchUploadedItems()
                self?.refreshEnd.accept(())
            })
            .disposed(by: disposeBag)
        
        selectedRow
            .withLatestFrom(itemList) { idx, items in
                items[idx]
            }
            .bind(to: moveToDetailVC)
            .disposed(by: disposeBag)
    }
    func fetchUploadedItems() {
        FIRManager.getAllItemList()
            .bind(to: self.itemList)
            .disposed(by: disposeBag)
    }
}
