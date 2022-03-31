# Firestore & Storage를 이용한 CRUD 구현

### 라이브러리
- SnapKit
- Kingfisher
- RxSwift
- FirebaseFirestore
- FirebaseStorage

### 기능
- **Create**
    - Firestore에 저장 -> `setData` 메서드 사용
    - Storage에 이미지 저장 -> `putData` 메서드 사용
    - Storage에 저장한 이미지의 URL 받기 -> `downloadURL` 메서드 사용
    - 파이어스토어에 상품의 `이름`, `가격`, `수량`, `설명`, `이미지 URL`, `Storage에 저장되어있는 이미지 경로`를 저장한다
    - 이미지가 있을 때, 없을 때를 구분하여 저장한다
    - 이미지가 있다면 Storage에 이미지를 저장한 후 이미지 URL을 받아서 Firestore에 저장
    - 이미지가 없다면 바로 Firestore에 저장
``` swift
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
```
- **Read**
    - `getDocuments` 메서드를 사용
    - Collection의 이름으로 Firestore에 저장되어 있는 상품들을 배열로 받아온다
``` swift
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
```

- **Update**
    - `updateData` 메서드를 사용
    - 이미지를 다른 이미지로 수정할 때, 이미지를 제거할 때로 구분하여 수정
    - 이미지를 다른 이미지로 수정한다면 수정할 이미지도 Storage에 저장한 후 이미지 URL을 받아서 Firestore에 수정
    - Firestore에서 이미지 경로 배열에 지금까지 설정했던 이미지들의 경로를 추가하여 저장
    - 이미지를 제거한다면 이미지 URL을 빈 문자열("")로 저장한다
    
``` swift
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
```

- **Delete**
    - `delete` 메서드 사용(Firestore, Storage 메서드 명 동일)
    - 이미지 경로 배열에 있는 모든 이미지들을 Storage에서 삭제한다
``` swift
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
```
