//
//  UploadViewModel.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/12.
//

import UIKit
import RxSwift
import RxRelay
import Firebase
import PhotosUI

class UploadViewModel {
    let disposeBag = DisposeBag()
    let FIRManager = FirestoreManager()
    
    let itemInfoInput = BehaviorSubject<(
        name: String,
        price: Int,
        count: Int,
        description: String
    )>(value: (
        name: "",
        price: 0,
        count: 1,
        description: ""
    ))
    let didTapUploadBarButton = PublishRelay<(UploadMode, Item?)>()
    let didTapImageSelectButton = PublishRelay<Void>()
    let presentToImagePicker = PublishSubject<PHPickerViewController>()
    let selectedImage = PublishSubject<UIImage>()
    
    init() {
        // New Upload
        didTapUploadBarButton
            .filter { $0.0 == .new }
            .withLatestFrom(itemInfoInput)
            .map { Item(name: $0, price: $1, count: $2, description: $3) }
            .subscribe(onNext: { [weak self] item in
                self?.FIRManager.uploadItem(item: item)
            })
            .disposed(by: disposeBag)
        
        // Modify Upload
        didTapUploadBarButton
            .filter { $0.0 == .modify }
            .compactMap { $0.1 }
            .map { (id: $0.id, itemInfo: try self.itemInfoInput.value()) }
            .subscribe(onNext: { [weak self] newItem in
                self?.FIRManager.updateItem(
                    id: newItem.id,
                    name: newItem.itemInfo.name,
                    price: newItem.itemInfo.price,
                    count: newItem.itemInfo.count,
                    description: newItem.itemInfo.description
                )
            })
            .disposed(by: disposeBag)
        
        didTapImageSelectButton
            .map {
                let pickerConfiguration = PHPickerConfiguration()
                let imagePicker = PHPickerViewController(configuration: pickerConfiguration)
                imagePicker.delegate = self
                return imagePicker
            }
            .bind(to: self.presentToImagePicker)
            .disposed(by: disposeBag)
    }
}

extension UploadViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image as? UIImage {
                    self.selectedImage.onNext(image)
                }
                if let error = error {
                    print("UploadViewModel - PHPickerViewControllerDelegate - picker - error : \(error.localizedDescription)")
                }
            }
        }
    }
}
