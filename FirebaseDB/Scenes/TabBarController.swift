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
        
        let tabBarItems: [UIViewController] = TabBarItem.allCases
            .map { tabBarCase in
                let vc = tabBarCase.vc
                vc.tabBarItem = UITabBarItem(
                    title: tabBarCase.title,
                    image: tabBarCase.icon.image,
                    selectedImage: tabBarCase.icon.selected
                )
                return vc
            }
        
        viewControllers = tabBarItems
    }
}
