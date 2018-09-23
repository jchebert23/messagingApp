//
//  MessageVC.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/21/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class MessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var sendButoon: UIButton!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var messageId: String!
    
    var messages = [Message]()
    
    var members = [String]()
    
    var groupName: String!
    
    var message: Message!
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var recipient: String!

    override func viewDidLoad() {

        super.viewDidLoad()
        //new stuff
        let nibName = UINib(nibName: "PostCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "PostCell")
        //end of new stuff
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.estimatedRowHeight = 300
        
        print("In message vc")
        if(groupName == nil)
        {
            groupName = "no group name"
        }
        //if the conversation existed in the past, load the data of the previous messages
        if messageId != "" && messageId != nil {
            loadData()
        }
        
        //i guess this brings up the keyboard?
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)){
            self.moveToBottom()
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notify: NSNotification){
        if let keyboardSize = (notify.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notify: NSNotification){
        if let keyboardSize = (notify.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @objc func dismissKeyboard(){
        
        
        view.endEditing(true)
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]
 
        //goes through each message object and configures it to a cell, config cell function is in MessagesCell class
         let cell = tableView.dequeueReusableCell(withIdentifier: "Message") as! MessagesCell
         cell.configCell(message: message)
         return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func loadData(){
        //loads all messages from messageId
        Database.database().reference().child("messages").child(messageId).observe(.value , with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                //clears out anything in messages variable
                self.messages.removeAll()
                
                //basically this grabs all the messages associated with the messageID (should probably be called conversation ID)
                //stores it in this array of Message objects called messages
                for data in snapshot{
                    if let postDict = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        let post = Message(messageKey: key, postData: postDict)
                        self.messages.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }

    func moveToBottom(){
        if messages.count > 0{
            let indexPath = IndexPath(row: messages.count - 1 , section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        
    }
    //when someone presses the send button
    @IBAction func sendPressed (_ sender: AnyObject){
        dismissKeyboard()
        
        if(messageField.text != nil && messageField.text != ""){
            
                let post: Dictionary <String, AnyObject> = [
                    "message": messageField.text as AnyObject,
                    "sender": currentUser as AnyObject,
                    "group": recipient as AnyObject,
                    "groupName": groupName as AnyObject
                ]
                
                var message: Dictionary <String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": recipient as AnyObject,
                    "groupName": groupName as AnyObject
                ]
                
                let recipientMessage2: Dictionary <String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": recipient as AnyObject,
                    "groupName": groupName as AnyObject
                ]
                
                //creating message id
                if messageId == nil {
                messageId = Database.database().reference().child("messages").childByAutoId().key
                }
                //creating then tree under
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                
                //this creates the message and sender under the message id

                firebaseMessage.setValue(post)
                if(members != [])
                {
                    ////ADD CODE HERE ABOUT ASSOCIATING MESSAGE ID with group name
                    
                    ////
                    for member in members {
 
                        if(member != currentUser)
                        {
                            let recipientMessage = Database.database().reference().child("Users").child(member).child("messages").child(messageId)
            
                            recipientMessage.setValue(recipientMessage2)
                        }
                    }
                }
                else
                {
 
                    let recipentMessage = Database.database().reference().child("Users").child(recipient).child("messages").child(messageId)
             
                    recipentMessage.setValue(recipientMessage2)
                }
                //under new users tab, userID->messages->messageID
                
                //does same thing as above, two lines of code above, but just makes tree for the user
                let userMessage = Database.database().reference().child("Users").child(currentUser!).child("messages").child(messageId)
                
                
                userMessage.setValue(message)
                
                loadData()
            

            
            messageField.text = ""
        }
        moveToBottom()
    }
    
    @IBAction func backPressed (_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }
}
