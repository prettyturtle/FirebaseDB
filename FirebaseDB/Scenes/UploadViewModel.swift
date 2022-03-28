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
    let selectedImage = BehaviorSubject<UIImage?>(value: nil)
    let savedImageURLInStorage = PublishSubject<String>()
    
    init() {
        let itemInfoObservable = Observable.combineLatest(selectedImage, itemInfoInput) { (image: $0, info: $1) }
        
        // 상품 등록
        didTapUploadBarButton
            .filter { $0.0 == .new }
            .withLatestFrom(itemInfoObservable)
            .map { [weak self] in
                self?.FIRManager.uploadItem(
                    imageTitle: UUID().uuidString,
                    image: $0.image,
                    name: $0.info.name,
                    price: $0.info.price,
                    count: $0.info.count,
                    description: $0.info.description
                )
            }
            .subscribe(onNext: {
                print("상품 업로드 성공!!")
            })
            .disposed(by: disposeBag)
        
        // 상품 수정
        didTapUploadBarButton
            .filter { $0.0 == .modify }
            .compactMap { $0.1 }
            .withLatestFrom(itemInfoObservable) {
                (
                    id: $0.id,
                    image: $1.image,
                    name: $1.info.name,
                    price: $1.info.price,
                    count: $1.info.count,
                    description: $1.info.description
                )
            }
            .map { [weak self] newItem in
                self?.FIRManager.updateItem(
                    id: newItem.id,
                    imageTitle: UUID().uuidString,
                    image: newItem.image,
                    name: newItem.name,
                    price: newItem.price,
                    count: newItem.count,
                    description: newItem.description
                )
            }
            .subscribe(onNext: {
                print("상품 수정 완료!!")
            })
            .disposed(by: disposeBag)
        
        // 이미지 선택 버튼이 눌렸을 때, PHPickerViewController를 presentToImagePicker와 bind
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

// MARK: - PHPickerViewControllerDelegate
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
