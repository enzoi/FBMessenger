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

extension FriendsViewController: CreateTextDelegate {
    
    func clearData() {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        if let context = delegate?.context {
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch let error {
                print (error)
            }
        }
    }
    
    func loadData(completion: @escaping (MessagesResult) -> Void) {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let friends = fetchFriends() {

            var finalMessages = [Message]()
            
            for friend in friends {
 
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                fetchRequest.fetchLimit = 1
                
                if let context = delegate?.context {
                    do {
                        let latestMessage = try context.fetch(fetchRequest) as? [Message]
                        finalMessages.append((latestMessage?.first)!)
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            print(finalMessages)
            let sortedMessages = finalMessages.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
            completion(.success(sortedMessages))
            
        }
    }
    
    func setupData() {
        
        clearData()

        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.context {
            let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            
            mark.name = "Mark Zuckerberg"
            mark.profileImageName = "zuckprofile"
            
            let messageFromMark = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            messageFromMark.text = "Hello. My name is Mark. Nice to meet you..."
            messageFromMark.date = NSDate()
            messageFromMark.isSender = false
            
            createMessageWithFriend(message: messageFromMark, friend: mark, context: context)
            
            let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            donald.name = "Donald Trump"
            donald.profileImageName = "donald_trump_profile"
            
            let messageFromDonald = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            messageFromDonald.text = "You're fired!!!"
            messageFromDonald.date = NSDate()
            messageFromDonald.isSender = false
            
            createMessageWithFriend(message: messageFromDonald, friend: donald, context: context)
            
            let gandhi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            gandhi.name = "Mahatma Gandhi"
            gandhi.profileImageName = "gandhi"
            
            let messageFromGandhi = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            messageFromGandhi.text = "Love, Peace, and Joy"
            messageFromGandhi.date = NSDate()
            messageFromGandhi.isSender = false
            createMessageWithFriend(message: messageFromGandhi, friend: gandhi, context: context)
            
            let hillary = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            hillary.name = "Hillary Clinton"
            hillary.profileImageName = "hillary_profile"
            
            let messageFromHillary = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            messageFromHillary.text = "Please vote for me, you did for Billy"
            messageFromHillary.date = NSDate()
            messageFromHillary.isSender = false
            
            createMessageWithFriend(message: messageFromHillary, friend: hillary, context: context)
            
            createSteveMessagesWithContext(context: context)
            
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
    }
    
    private func createSteveMessagesWithContext(context: NSManagedObjectContext) {
        let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        
        let messageFromSteve1 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        messageFromSteve1.text = "Stay hungry, stay foolish..."
        messageFromSteve1.date = NSDate()
        messageFromSteve1.isSender = false
         createMessageWithFriend(message: messageFromSteve1, friend: steve, context: context)

        let messageFromSteve2 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        messageFromSteve2.text = "Hello, how are you? Hope you are having a good morning"
        messageFromSteve2.date = NSDate()
        messageFromSteve2.isSender = false
        createMessageWithFriend(message: messageFromSteve2, friend: steve, context: context)
        
        let messageFromSteve3 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        messageFromSteve3.text = "Are you interested in buying an Apple device? We have wide variety of devices that suit your needs. Please make your purchase with us!!"
        messageFromSteve3.date = NSDate()
        messageFromSteve3.isSender = false
        createMessageWithFriend(message: messageFromSteve3, friend: steve, context: context)
        
        let messageFromSteve4 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        messageFromSteve4.text = "Yes, totally looking to buy an iPhone X"
        messageFromSteve4.date = NSDate()
        messageFromSteve4.isSender = true
        createMessageWithFriend(message: messageFromSteve4, friend: steve, context: context)
        
        let messageFromSteve5 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        messageFromSteve5.text = "Totally understand that you want the new iPhone X, but you'll have to wait until September for the new release. Sorry but that's just how Apple likes to do things."
        messageFromSteve5.date = NSDate()
        messageFromSteve5.isSender = false
        createMessageWithFriend(message: messageFromSteve5, friend: steve, context: context)
        
        let messageFromSteve6 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        messageFromSteve6.text = "Absolutely, I'll just use my gigantic iPhone 6 Plus until then!!!"
        messageFromSteve6.date = NSDate()
        messageFromSteve6.isSender = false
        createMessageWithFriend(message: messageFromSteve6, friend: steve, context: context)
    }
    
    func createMessageWithFriend(message: Message, friend: Friend, context: NSManagedObjectContext) {
        
        friend.addToMessages(message)
        
        do {
            try context.save()
            
        } catch let error {
            print(error)
        }
    }
    
    func createMessageWithText(message: Message, friend: Friend, context: NSManagedObjectContext, isSender: Bool) {
        
        friend.addToMessages(message)

    }
    
    func fetchFriends() -> [Friend]? {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        
        if let context = delegate?.context {
            do {
                return try context.fetch(request) as? [Friend]
                
            } catch let error {
                print(error)
            }
        }
        return nil
    }
}
