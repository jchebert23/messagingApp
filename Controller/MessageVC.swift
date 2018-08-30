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
    //NEW STUFF
    var messageData = [String]()
    //END OF NEW STUFF
    var messageId: String!
    
    var messages = [Message]()
    
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
        
        if messageId != "" && messageId != nil {
            loadData()
        }
        
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
      
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Message") as? MessagesCell {
            cell.configCell(message: message)
            return cell
        } else{
            return MessagesCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func loadData(){
        Database.database().reference().child("messages").child(messageId).observe(.value , with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.messages.removeAll()
                
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
            if messageId == nil {
                let post: Dictionary <String, AnyObject> = [
                    "message": messageField.text as AnyObject,
                    "sender": recipient as AnyObject
                ]
                
                let message: Dictionary <String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": recipient as AnyObject
                ]
                
                let recipientMessage: Dictionary <String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": currentUser as AnyObject
                ]
                
                //repeating myself
                
                messageId = Database.database().reference().child("messages").childByAutoId().key
                
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                
                firebaseMessage.setValue(post)
                
                let recipentMessage = Database.database().reference().child("users").child(recipient).child("messages").child(messageId)
                
                recipentMessage.setValue(recipientMessage)
                
                //maybe change this 27:51, episode 5
                let userMessage = Database.database().reference().child("users").child(currentUser!).child("messages").child(messageId)
                
                userMessage.setValue(message)
                
                loadData()
            } else if messageId != ""{
                let post: Dictionary <String, AnyObject> = [
                    "message": messageField.text as AnyObject,
                    "sender": recipient as AnyObject
                ]
                
                let message: Dictionary <String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": recipient as AnyObject
                ]
                
                let recipientMessage: Dictionary <String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": currentUser as AnyObject
                ]
                //same thing as above but no messageId
                
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                
                firebaseMessage.setValue(post)
                
                let recipentMessage = Database.database().reference().child("users").child(recipient).child("messages").child(messageId)
                
                recipentMessage.setValue(recipientMessage)
                
                //maybe change this 27:51, episode 5
                let userMessage = Database.database().reference().child("users").child(currentUser!).child("messages").child(messageId)
                
                userMessage.setValue(message)
                
                loadData()
            }
            
            messageField.text = ""
        }
        moveToBottom()
    }
    
    @IBAction func backPressed (_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }
}
