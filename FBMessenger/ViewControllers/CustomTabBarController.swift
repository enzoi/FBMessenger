//
//  CustomTabBarController.swift
//  FBMessenger
//
//  Created by Yeontae Kim on 5/7/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsViewController(collectionViewLayout: layout)
        let recentMessageNavController = UINavigationController(rootViewController: friendsController)
        recentMessageNavController.tabBarItem.title = "Recent"
        recentMessageNavController.tabBarItem.image = UIImage(named: "recent")
        
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = "Cells"
        navController.tabBarItem.image = UIImage(named: "cells")
        
        viewControllers = [recentMessageNavController, navController]
    }
}
