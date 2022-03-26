//
//  FIRManager.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/15.
//

import UIKit
import Firebase
import RxSwift

struct FirestoreManager {
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - Firestore
    func uploadItem(item: Item) {
        let data = [
            "id": item.id,
            "imageURL": item.imageURL,
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
                              let imageURL = document["imageURL"] as? String,
                              let name = document["name"] as? String,
                              let price = document["price"] as? Int,
                              let count = document["count"] as? Int,
                              let description = document["description"] as? String else { return }
                        
                        let item = Item(
                            id: id,
                            imageURL: imageURL,
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
    // TODO: - 이미지 추가로 인한 수정 필요
    func updateItem(
        id: String,
        name: String,
        price: Int,
        count: Int,
        description: String
    ) {
        db.collection(CollectionType.upload.name)
            .document(id)
            .updateData(
                [
                    "name": name,
                    "price": price,
                    "count": count,
                    "description": description
                ]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("상품 수정 완료!!")
                    }
                }
    }
    
    // MARK: - Storage
    func uploadImageInStorage(id: String, image: UIImage) -> PublishSubject<String> {
        let retPublishSubject = PublishSubject<String>()
        if let imagePngData = image.pngData() {
            let filePath = "images/\(id)"
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            let storageRef = storage.reference()
            let uploadPath = storageRef.child(filePath)
            
            uploadPath.putData(imagePngData, metadata: metaData) { metaData, error in
                if let error = error {
                    print("FirestoreManager - Storage - uploadImageReturnURL - putData - ERROR: \(error.localizedDescription)")
                    return
                } else {
                    print("사진 Storage에 업로드 성공!!")
                    
                    uploadPath.downloadURL { url, error in
                        if let error = error {
                            print("FirestoreManager - Storage - uploadImageReturnURL - downloadURL - ERROR: \(error.localizedDescription)")
                            return
                        }
                        if let url = url {
                            let urlString = url.absoluteString
                            retPublishSubject.onNext(urlString)
                        }
                    }
                }
            }
        }
        return retPublishSubject
    }
}
