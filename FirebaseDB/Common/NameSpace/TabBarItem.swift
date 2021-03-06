//
//  TabBarItem.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/22.
//

import UIKit

enum TabBarItem: CaseIterable {
    case upload
    case itemList
    
    var vc: UIViewController {
        switch self {
        case .upload:
            let rootVC = UploadViewController()
            rootVC.bind(viewModel: UploadViewModel())
            return UINavigationController(rootViewController: rootVC)
        case .itemList:
            let rootVC = ItemListViewController()
            rootVC.bind(viewModel: ItemListViewModel())
            return UINavigationController(rootViewController: rootVC)
        }
    }
    var title: String {
        switch self {
        case .upload: return "등록"
        case .itemList: return "목록"
        }
    }
    var icon: (image: UIImage?, selected: UIImage?) {
        switch self {
        case .upload: return (UIImage(systemName: "plus.circle"), UIImage(systemName: "plus.circle.fill"))
        case .itemList: return (UIImage(systemName: "list.bullet"), UIImage(systemName: "list.bullet.indent"))
        }
    }
}
