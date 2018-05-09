//
//  AppDelegate.swift
//  FBMessenger
//
//  Created by Yeontae Kim on 1/31/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack(modelName: "FBMessenger")
    var context: NSManagedObjectContext?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        window?.rootViewController = CustomTabBarController()
        
        context = coreDataStack.managedContext
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }

}

