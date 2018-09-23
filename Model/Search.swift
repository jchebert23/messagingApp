//
//  File.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/21/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper


class Search {
    private var _username: String!
    private var _userImg: String!
    var _previousMessageId: String!
    var _userKey: String!
    var _members : [String]
    var _groupName: String!
    private var _userRef: DatabaseReference!
    var debugPrint: Bool! = true
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var groupName: String{
        return _groupName
    }
    
    var username: String{
        return _username
    }
    
    var userImg: String{
        return _userImg
    }
    
    var userKey: String{
        return _userKey
    }
    
    init(username: String, userImg: String, members: [String]){
        _username = username
        _userImg = userImg
        _members = members
    }
    
    init(userKey: String, postData: Dictionary<String, AnyObject>, usersPreviousMessages: [String: AnyObject]){
        _userKey = userKey
        for (mesId, mesInfo) in usersPreviousMessages
        {
            print("Message ID")
            print(mesId)
            print(mesInfo)
            var newInfo = mesInfo as? Dictionary<String, String>
            if(newInfo!["recipient"] == userKey)
            {
                print("HERE LINE 52")
                _previousMessageId = mesId
                break
            }
        }
        
    
        
        if let username = postData["username"] as? String{
            _username = username
            print("here in Search class")
            _groupName = "no group name"
        }
            
        else if let username = postData["name"] as? String{
            _username = username
            print("here in Search class2")
            print(postData)
            _groupName = username
        }
        
        print("USERNAME ASSOCIATED WITH SEARCH CELL")
        print(_username)
        
        if let userImg = postData["prof-pic"] as? String {
            if(self.debugPrint){
                print(userImg)
            }
            _userImg = userImg
        }
        else if let userImg = postData["group-pic"] as? String {
            _userImg = userImg
        }
        else{
            _userImg = "https://firebasestorage.googleapis.com/v0/b/plusonetest-2143.appspot.com/o/profile-pics%2Fdbooth23?alt=media&token=91d830d1-0738-4576-8cec-0b45a34f6f4e"
        }
        
        if let members = postData["members"] as? [String] {
            _members = members
            print(_members)
        }
        else
        {
            _members = []
        }
        
        if let groupName = postData["name"] as? String!
        {
            _groupName = groupName
        }
        else
        {
            _groupName = "no group name"
        }
        
        _userRef = Database.database().reference().child("messages").child(_userKey)
        
    }
    
}
