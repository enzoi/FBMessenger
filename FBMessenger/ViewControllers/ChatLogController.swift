//
//  ChatLogController.swift
//  FBMessenger
//
//  Created by Yeontae Kim on 5/7/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit
import CoreData

protocol CreateTextDelegate: class {
    func createMessageWithText(message: Message, friend: Friend)
}

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: CreateTextDelegate?
    private let cellId = "cellId"
    var messages: [Message]?
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
            messages = friend?.messages?.allObjects as? [Message]
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        collectionView?.register(ChatLogFriendCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView?.backgroundColor = .white
        
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setupInputComponents() {
        let topBoarderView = UIView()
        topBoarderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBoarderView)
        
        messageInputContainerView.addConstraintsWithFormat("H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraintsWithFormat("H:|[v0]|", views: topBoarderView)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0(0.5)]", views: topBoarderView)
    }
    
    
    // MARK: - Selector methods
    
    @objc func handleSend() {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let context = appDelegate?.context else { return }
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.text = inputTextField.text!
        message.date = NSDate()
        message.isSender = true
        
        delegate?.createMessageWithText(message: message, friend: friend!)
        
        do {
            try context.save()
            
            messages?.append(message)
            
            let item: Int = messages!.count - 1
            let insertionIndexPath = IndexPath(item: item, section: 0)
            collectionView?.insertItems(at: [insertionIndexPath])
            collectionView?.scrollToItem(at: insertionIndexPath, at: .bottom, animated: true)
            inputTextField.text = nil
            
        } catch let error {
            print(error)
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow

            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
                if isKeyboardShowing {
                    let indexPath = IndexPath(item: self.messages!.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            })
        }
    }

    
    // MARK: - collectionView methods
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("clicked")
        inputTextField.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogFriendCell
        
        cell.messageTextView.text = messages?[indexPath.item].text
        
        if let message = messages?[indexPath.item],
            let messageText = messages?[indexPath.item].text,
            let profileImageName = messages?[indexPath.item].friend?.profileImageName {
            
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            if !message.isSender {
                cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
                
                cell.profileImageView.isHidden = false
                
                // cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleImageView.image = ChatLogFriendCell.grayBubbleImage
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = .black
                
            } else {
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                
                cell.profileImageView.isHidden = true
                
                // cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.bubbleImageView.image = ChatLogFriendCell.blueBubbleImage
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = .white
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let messageText = messages?[indexPath.item].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
}
