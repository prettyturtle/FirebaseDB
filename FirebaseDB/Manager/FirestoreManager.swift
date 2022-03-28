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
    
    /// 상품을 업로드 하는 메서드
    ///
    /// 상품의 이미지가 있다면 이미지를 파이어베이스 스토리지에 저장한 후 다운로드 URL을 받아 파이어스토어에 저장
    /// 상품의 이미지가 없다면 파이어스토어에 저장, imageURL는 빈 문자열("")로 저장된다
    /// - imageTitle: 상품 이미지의 제목이 되는 값
    func uploadItem(
        imageTitle: String,
        image: UIImage?,
        name: String,
        price: Int,
        count: Int,
        description: String
    ) {
        if let imageData = image?.pngData() { // 이미지가 있을 때
            let storageRef = storage.reference()
            let filePath = "images/\(imageTitle)"
            let storageChild = storageRef.child(filePath)
            let metaData = StorageMetadata()
            
            metaData.contentType = "image/png"
            
            storageChild.putData(imageData, metadata: metaData) { _, error in
                if let error = error {
                    print("ERROR - FirestoreManager - 이미지가 있을 때 - uploadItem - putData - \(error.localizedDescription)")
                    return
                } else {
                    print("사진 업로드 성공!!")
                    
                    storageChild.downloadURL { url, error in
                        if let error = error {
                            print("ERROR - FirestoreManager - 이미지가 있을 때 - uploadItem - downloadURL - \(error.localizedDescription)")
                            return
                        }
                        
                        if let url = url {
                            let imageURL = url.absoluteString
                            let item = Item(
                                imageURL: imageURL,
                                name: name,
                                price: price,
                                count: count,
                                description: description
                            )
                            let documentData = [
                                "id": item.id,
                                "imageURL": item.imageURL,
                                "name": item.name,
                                "price": item.price,
                                "count": item.count,
                                "description": item.description
                            ] as [String: Any]
                            
                            db.collection(CollectionType.upload.name)
                                .document(item.id)
                                .setData(documentData) { error in
                                    if let error = error {
                                        print("ERROR - FirestoreManager - 이미지가 있을 때 - uploadItem - setData - \(error.localizedDescription)")
                                    } else {
                                        print("상품 업로드 성공!!")
                                    }
                                }
                        }
                    }
                }
            }
        } else { // 이미지가 없을 때
            let item = Item(
                imageURL: "",
                name: name,
                price: price,
                count: count,
                description: description
            )
            let documentData = [
                "id": item.id,
                "imageURL": item.imageURL,
                "name": item.name,
                "price": item.price,
                "count": item.count,
                "description": item.description
            ] as [String: Any]
            
            db.collection(CollectionType.upload.name)
                .document(item.id)
                .setData(documentData) { error in
                    if let error = error {
                        print("ERROR - FirestoreManager - 이미지가 없을 때 - save - setData - \(error.localizedDescription)")
                    } else {
                        print("상품 업로드 성공!!")
                    }
                }
        }
    }
    
    /// 파이어스토어에 저장되어 있는 상품들을 PublishSubject<[Item]>으로 반환하는 메서드
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
    
    /// 수정한 상품을 업데이트 하는 메서드
    ///
    /// 수정된 이미지를 저장한 후 downloadURL을 받고
    /// 원래 저장되어있던 id 값으로 파이어스토어에서 찾아 수정한다
    func updateItem(
        id: String,
        imageTitle: String,
        image: UIImage?,
        name: String,
        price: Int,
        count: Int,
        description: String
    ) {
        if let imageData = image?.pngData() { // 이미지가 있을 때
            let storageRef = storage.reference()
            let filePath = "images/\(imageTitle)"
            let storageChild = storageRef.child(filePath)
            let metaData = StorageMetadata()
            
            metaData.contentType = "image/png"
            
            storageChild.putData(imageData, metadata: metaData) { _, error in
                if let error = error {
                    print("ERROR - FirestoreManager - 이미지가 있을 때 - updateItem - putData - \(error.localizedDescription)")
                    return
                } else {
                    print("사진 수정 업로드 성공!!")
                    
                    storageChild.downloadURL { url, error in
                        if let error = error {
                            print("ERROR - FirestoreManager - 이미지가 있을 때 - updateItem - downloadURL - \(error.localizedDescription)")
                            return
                        }
                        if let url = url {
                            let imageURL = url.absoluteString
                            
                            db.collection(CollectionType.upload.name)
                                .document(id)
                                .updateData(
                                    [
                                        "imageURL": imageURL,
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
                    }
                }
            }
        }
        // TODO: - 선택한 이미지를 삭제하는 기능을 만든 뒤 추가
        // UploadViewController에서 수정하러 진입하면 이미지가 처음에 nil인 상황인데
        // 진입 시점에 이미지가 있다면 이미지를 UploadViewModel의 selectedImage에 onNext 해줘야한다
        else { print("이미지 없음") }
    }
}
