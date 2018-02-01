//
//  FriendsViewControllerHelper.swift
//  FBMessenger
//
//  Created by Yeontae Kim on 1/31/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit
import CoreData

enum MessagesResult {
    case success([Message])
    case failure(Error)
}

extension FriendsViewController {
    
    func clearData() {
        
        let context = self.coreDataStack.managedContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
            
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error {
            print (error)
        }
        
    }
    
    func loadData(completion: @escaping (MessagesResult) -> Void) {
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        let moc = coreDataStack.managedContext
        
        moc.perform {
            do {
                let messages = try moc.fetch(fetchRequest)
                completion(.success(messages))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func setupData() {
        
        clearData()
        
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
        
        do {
            try context.save()
        } catch let err {
            print(err)
        }
        

        loadData() { (messagesResult) in
            
            switch messagesResult {
                
            case let .success(messages):
                self.messages = messages
                self.collectionView?.reloadData()
                
            case .failure(_):
                self.messages = []
                
            }
        }

    }
}
