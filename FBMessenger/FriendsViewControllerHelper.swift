//
//  FriendsViewControllerHelper.swift
//  FBMessenger
//
//  Created by Yeontae Kim on 1/31/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit
import CoreData

extension FriendsViewController {
    
    func setupData() {
        
        let context = self.coreDataStack.managedContext
        
        let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend

        mark.name = "Mark Zuckerberg"
        mark.profileImageName = "zuckprofile"
        
        let message1 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message1.text = "Hello. My name is Mark. Nice to meet you..."
        message1.date = NSDate()
        message1.friend = mark
        
        let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        
        let message2 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message2.text = "Stay hungry, stay foolish..."
        message2.date = NSDate()
        message2.friend = steve
        
        messages = [message1, message2]
    }
    
    
    
    
}
