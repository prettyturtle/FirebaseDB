//
//  StorageViewController.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/26.
//

import UIKit
import SnapKit
import RxSwift
import FirebaseStorage

class StorageViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let button = UIButton()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        attr()
        bind()
    }
    var count = 1
    func bind() {
        button.rx.tap
            .subscribe(onNext: {
                self.up(name: "\(self.count)")
                self.count += 1
            })
            .disposed(by: disposeBag)
    }
    
    func up(name: String) {
        let url = URL(string: "https://picsum.photos/2560/1440/?random")!
        let data = try! Data(contentsOf: url)
        
        let filePath = "images/\(name).png"
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storage.reference().child(filePath).putData(data, metadata: metaData) { metaData, error in
            if let error = error {
                print("ERROR1: \(error.localizedDescription)")
                return
            } else {
                print("성공")
                
                self.storage.reference().child(filePath).downloadURL { url, error in
                    if let error = error {
                        print("ERROR2: \(error.localizedDescription)")
                        return
                    } else {
                        print("URL: \(url)")
                    }
                }
            }
        }
    }
    
    func attr() {
        button.setTitle("업로드", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemMint
        button.layer.cornerRadius = 4.0
    }
    func layout() {
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.height.equalTo(48.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.centerY.equalToSuperview()
        }
    }
}
