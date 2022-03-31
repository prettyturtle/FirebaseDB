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
    
    let uploadResult = PublishSubject<(String?, Error?)>()
    
    /// 상품을 업로드 하는 메서드
    ///
    /// 상품의 이미지가 있다면 이미지를 파이어베이스 스토리지에 저장한 후 다운로드 URL을 받아 파이어스토어에 저장
    ///
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
                    uploadResult.onNext((nil, error))
                    return
                } else {
                    print("사진 업로드 성공!!")
                    
                    storageChild.downloadURL { url, error in
                        if let error = error {
                            print("ERROR - FirestoreManager - 이미지가 있을 때 - uploadItem - downloadURL - \(error.localizedDescription)")
                            uploadResult.onNext((nil, error))
                            return
                        }
                        
                        if let url = url {
                            let imageURL = url.absoluteString
                            let item = Item(
                                imageURL: imageURL,
                                imagePath: [imageTitle],
                                name: name,
                                price: price,
                                count: count,
                                description: description
                            )
                            let documentData = [
                                "id": item.id,
                                "imageURL": item.imageURL,
                                "imagePath": item.imagePath,
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
                                        uploadResult.onNext((nil, error))
                                    } else {
                                        print("상품 업로드 성공!!")
                                        uploadResult.onNext(("상품 등록 완료!", nil))
                                    }
                                }
                        }
                    }
                }
            }
        } else { // 이미지가 없을 때
            let item = Item(
                imageURL: "",
                imagePath: [],
                name: name,
                price: price,
                count: count,
                description: description
            )
            let documentData = [
                "id": item.id,
                "imageURL": item.imageURL,
                "imagePath": item.imagePath,
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
                        uploadResult.onNext((nil, error))
                    } else {
                        print("상품 업로드 성공!!")
                        uploadResult.onNext(("상품 등록 완료!", nil))
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
                              let imagePath = document["imagePath"] as? [String],
                              let name = document["name"] as? String,
                              let price = document["price"] as? Int,
                              let count = document["count"] as? Int,
                              let description = document["description"] as? String else { return }
                        
                        let item = Item(
                            id: id,
                            imageURL: imageURL,
                            imagePath: imagePath,
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
    ///
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
        db.collection(CollectionType.upload.name)
            .document(id)
            .getDocument { snapshot, error in
                if let error = error {
                    print("ERROR - FirstoreManager - updateItem - getDocument - \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot {
                    guard let data = snapshot.data(),
                          let currentImagePath = data["imagePath"] as? [String] else { return }
                    
                    if let imageData = image?.pngData() { // 이미지가 있을 때
                        let storageRef = storage.reference()
                        let filePath = "images/\(imageTitle)"
                        let storageChild = storageRef.child(filePath)
                        let metaData = StorageMetadata()
                        
                        metaData.contentType = "image/png"
                        
                        storageChild.putData(imageData, metadata: metaData) { _, error in
                            if let error = error {
                                print("ERROR - FirestoreManager - 이미지가 있을 때 - updateItem - putData - \(error.localizedDescription)")
                                uploadResult.onNext((nil, error))
                                return
                            } else {
                                print("사진 수정 업로드 성공!!")
                                
                                storageChild.downloadURL { url, error in
                                    if let error = error {
                                        print("ERROR - FirestoreManager - 이미지가 있을 때 - updateItem - downloadURL - \(error.localizedDescription)")
                                        uploadResult.onNext((nil, error))
                                        return
                                    }
                                    if let url = url {
                                        let imageURL = url.absoluteString
                                        
                                        db.collection(CollectionType.upload.name)
                                            .document(id)
                                            .updateData(
                                                [
                                                    "imageURL": imageURL,
                                                    "imagePath": currentImagePath + [imageTitle],
                                                    "name": name,
                                                    "price": price,
                                                    "count": count,
                                                    "description": description
                                                ]) { error in
                                                    if let error = error {
                                                        print("ERROR - FirestoreManager - 이미지가 있을 때 - updateItem - updateData - \(error.localizedDescription)")
                                                        uploadResult.onNext((nil, error))
                                                    } else {
                                                        print("상품 수정 완료!!")
                                                        uploadResult.onNext(("상품 수정 완료!", nil))
                                                    }
                                                }
                                    }
                                }
                            }
                        }
                    } else { // 이미지가 없을 때
                        db.collection(CollectionType.upload.name)
                            .document(id)
                            .updateData(
                                [
                                    "imageURL": "",
                                    "imagePath": currentImagePath,
                                    "name": name,
                                    "price": price,
                                    "count": count,
                                    "description": description
                                ]) { error in
                                    if let error = error {
                                        print("ERROR - FirestoreManager - 이미지가 없을 때 - updateItem - updateData - \(error.localizedDescription)")
                                        uploadResult.onNext((nil, error))
                                    } else {
                                        print("상품 수정 완료!!")
                                        uploadResult.onNext(("상품 수정 완료!!", nil))
                                    }
                                }
                    }
                }
            }
    }
    
    /// 상품을 삭제하는 메서드
    ///
    /// 파이어스토어에서 상품을 삭제한다
    ///
    /// 스토리지에 저장 되어 있는 사진들도 함께 삭제된다
    func deleteItem(item: Item) {
        let storageRef = storage.reference()
        let imagePath = item.imagePath
        
        for path in imagePath {
            let filePath = "images/\(path)"
            let storageChild = storageRef.child(filePath)
            
            storageChild.delete { error in
                if let error = error {
                    print("ERROR - FirestoreManager - deleteItem - Storage delete - \(error.localizedDescription)")
                } else {
                    print("스토리지에서 이미지들 삭제 성공!!")
                }
            }
        }
        
        db.collection(CollectionType.upload.name)
            .document(item.id)
            .delete { error in
                if let error = error {
                    print("ERROR - FirestoreManager - deleteItem - \(error.localizedDescription)")
                } else {
                    print("삭제 성공!!")
                }
            }
    }
}
