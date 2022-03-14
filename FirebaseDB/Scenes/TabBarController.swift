//
//  TabBarController.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/13.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uploadVC = UINavigationController(rootViewController: UploadViewController())
        let itemListVC = UINavigationController(rootViewController: ItemListViewController())
        
        uploadVC.tabBarItem = UITabBarItem(
            title: "등록",
            image: UIImage(systemName: "plus.circle"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )
        itemListVC.tabBarItem = UITabBarItem(
            title: "목록",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet.indent")
        )
        
        viewControllers = [uploadVC, itemListVC]
    }
}
