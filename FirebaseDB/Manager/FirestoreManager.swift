//
//  FIRManager.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/15.
//

import Foundation
import Firebase
import RxSwift

struct FirestoreManager {
    private let db = Firestore.firestore()
    
    func getAllItemList() -> BehaviorSubject<[Item]> {
        var itemList = [Item]()
        let itemListSubject = BehaviorSubject<[Item]>(value: [])
        db.collection("UploadedItems")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("FirestoreManager-getAllItemList-ERROR: \(error)")
                }
                
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        guard let id = document["id"] as? String,
                              let name = document["name"] as? String,
                              let price = document["price"] as? String,
                              let count = document["count"] as? Int,
                              let description = document["description"] as? String else { return }
                        
                        let item = Item(
                            id: id,
                            name: name,
                            price: price,
                            count: count,
                            description: description
                        )
                        itemList.append(item)
                    }
                    itemListSubject.onNext(itemList)
                }
            }
        return itemListSubject
    }
}
