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
        
        if let friends = fetchFriends() {

            var finalMessages = [Message]()
            
            for friend in friends {
 
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                fetchRequest.fetchLimit = 1
                
                let moc = coreDataStack.managedContext
                
                do {
                    let latestMessage = try moc.fetch(fetchRequest) as? [Message]
                    finalMessages.append((latestMessage?.first)!)
                } catch {
                    completion(.failure(error))
                }
            }
            
            let sortedMessages = finalMessages.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
            completion(.success(sortedMessages))
            
        }
    }
    
    func setupData() {
        
        clearData()
        
        let context = self.coreDataStack.managedContext
        
        let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend

        mark.name = "Mark Zuckerberg"
        mark.profileImageName = "zuckprofile"
        
        createMessageWithText(text: "Hello. My name is Mark. Nice to meet you...", friend: mark, minutesAgo: 5, context: context)
        
        let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        
        createMessageWithText(text: "Stay hungry, stay foolish...", friend: steve, minutesAgo: 3, context: context)
        createMessageWithText(text: "What's going on in Apple?", friend: steve, minutesAgo: 1, context: context)
        
        let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        donald.name = "Donald Trump"
        donald.profileImageName = "donald_trump_profile"
        
        createMessageWithText(text: "You're fired!!", friend: donald, minutesAgo: 10, context: context)
        
        do {
            try context.save()
        } catch let error {
            print(error)
        }

        loadData() { (messageResult) in
            
            switch messageResult {
                
            case let .success(messages):
                
                self.messages = messages
                self.collectionView?.reloadData()
                
            case .failure(_):
                self.messages = []
                
            }
        }
    }
    
    private func createMessageWithText(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext) {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.text = text
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
        message.friend = friend
        
        friend.addToMessages(message)
    }
    
    func fetchFriends() -> [Friend]? {
        
        let moc = coreDataStack.managedContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            
        do {
            return try moc.fetch(request) as? [Friend]
                
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
