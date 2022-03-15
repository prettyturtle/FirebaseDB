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
    enum CollectionType: String {
        case upload = "UploadedItems"
        
        var name: String { self.rawValue }
    }
    private let db = Firestore.firestore()
    
    func uploadItem(item: Item) {
        let data = [
            "id": item.id,
            "name": item.name,
            "price": item.price,
            "count": item.count,
            "description": item.description
        ] as [String : Any]
        
        db.collection(CollectionType.upload.name)
            .document(item.id)
            .setData(data) { error in
                if let error = error {
                    print("FirestoreManager - uploadItem - ERROR: \(error.localizedDescription)")
                } else {
                    print("상품 업로드 성공!!")
                }
            }
    }
    
    func getAllItemList() -> PublishSubject<[Item]> {
        var itemList = [Item]()
        let itemListSubject = PublishSubject<[Item]>()
        db.collection(CollectionType.upload.name)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("FirestoreManager-getAllItemList-ERROR: \(error)")
                }
                
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        guard let id = document["id"] as? String,
                              let name = document["name"] as? String,
                              let price = document["price"] as? Int,
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
