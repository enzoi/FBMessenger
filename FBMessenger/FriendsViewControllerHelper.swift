//
//  FriendsViewControllerHelper.swift
//  FBMessenger
//
//  Created by Yeontae Kim on 1/31/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit

class Friend: NSData {
    
    var name: String?
    var profileImageName: String?

}

class Message: NSData {
    
    var text: String?
    var date: NSDate?
    
    var friend: Friend?
    
}

extension FriendsViewController {
    
    func setupData() {
        
        let mark = Friend()
        mark.name = "Mark Zuckerberg"
        mark.profileImageName = "zuckprofile"
        
        let message1 = Message()
        message1.text = "Hello. My name is Mark. Nice to meet you..."
        message1.date = NSDate()
        message1.friend = mark
        
        let steve = Friend()
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        
        let message2 = Message()
        message2.text = "Stay hungry, stay foolish..."
        message2.date = NSDate()
        message2.friend = steve
        
        messages = [message1, message2]
    }
    
    
    
    
}
