//
//  MessageDetail.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/20/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class MessageDetail{
    private var _recipient: String!
    private var _messageKey: String!
    private var _messageRef: DatabaseReference!
    var _members = [String]()
    var _groupName: String!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    var recipient: String{
        return _recipient
    }
    
    var messageKey: String{
        return _messageKey
    }
    
    var messageRef: DatabaseReference{
        return _messageRef
    }
    
    
    init(recipient: String){
        _recipient=recipient
    }
    
    init(messageKey: String, messageData: Dictionary<String, AnyObject>){
        _messageKey = messageKey
        
        if let recipient = messageData["recipient"] as? String{
            _recipient = recipient
        }
        
        if let groupName = messageData["groupName"] as? String{
            NSLog("LINE NUMBER %d\n", #line)
            _groupName = groupName
        }
        else
        {
            _groupName = ""
        }
        NSLog("%s\n", _groupName)
        //NSLog("GROUP NAME: %s, %d\n", _groupName, #line)
        if(_groupName != "" && _groupName != nil)
        {
        Database.database().reference().child("Groups").child(recipient).observe(.value , with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value!.object(forKey: "members")!)
            self._members = ((value!.object(forKey: "members")!) as? [String])!
            }
            )
        }
        _messageRef = Database.database().reference().child("recipient").child(_messageKey)

    }
}
