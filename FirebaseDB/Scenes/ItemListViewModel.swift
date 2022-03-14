//
//  ItemListViewModel.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/13.
//

import Foundation
import RxSwift

class ItemListViewModel {
    
    let disposeBag = DisposeBag()
    let FIRManager = FirestoreManager()
    
    var itemList: BehaviorSubject<[Item]>
    
    init() {
        itemList = FIRManager.getAllItemList()
    }
}
