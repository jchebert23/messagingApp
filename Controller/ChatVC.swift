//
//  ChatVC.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/20/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper


class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var messageDetail = [MessageDetail]()
    
    var detail: MessageDetail!
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var recipient: String!
    
    var messageId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        Database.database().reference().child("Users").child(currentUser!).child("messages").observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.messageDetail.removeAll()
                
                for data in snapshot {
                    
                    if let messageDict = data.value as? Dictionary<String, AnyObject> {
                        
                        let key = data.key
                        let info = MessageDetail(messageKey: key, messageData: messageDict)
                        self.messageDetail.append(info)
                    }
                    
                }
                
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageDetail.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageDet = messageDetail[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? messageDetailCell{
            cell.configureCell(messageDetail: messageDet)
            return cell
        }
        else{
            return messageDetailCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipient = messageDetail[indexPath.row].recipient
        
        messageId = messageDetail[indexPath.row].messageRef.key
        
        performSegue(withIdentifier: "toMessages", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MessageVC{
            destinationViewController.recipient = recipient
            destinationViewController.messageId = messageId
        }
    }
    
    @IBAction func signOut(_ sender: AnyObject){
        try! Auth.auth().signOut()
        KeychainWrapper.standard.removeObject(forKey: "uid")
        dismiss(animated: true, completion: nil)
    }
    
}
