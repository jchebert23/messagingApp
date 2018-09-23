//
//  SearchVC.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/21/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Darwin

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var searchDetail = [Search]()
    var filteredDate = [Search]()
    var isSearching = false
    var detail: Search!
    var members = [String]()
    var groupName: String!
    var recipient: String!
    var messageId: String!
    var debugPrint: Bool = false
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        //grabbing list of users
        
        var usersPreviousMessages = [String: AnyObject]()
        
        Database.database().reference().child("Users").child(currentUser!).child("messages").observe(.value, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            usersPreviousMessages = value!
            print("USERS PREVIOUS MESSAGES1")
            print(usersPreviousMessages)
            
        })
        
        
        
        Database.database().reference().child("Users").observe(.value , with: { (snapshot) in
        let value = snapshot.value as? NSDictionary

                self.searchDetail.removeAll()

            
                for data in value!{
                    let postDict: NSDictionary = data.value as! NSDictionary
                    let key = data.key
                    let post = Search(userKey: key as! String, postData: postDict as! Dictionary<String, AnyObject>, usersPreviousMessages: usersPreviousMessages)
                        self.searchDetail.append(post)
                }
            
           
        })
        
        //grabbing list of group names
        
        
        Database.database().reference().child("Groups").observe(.value , with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for data in value!{

                let postDict: NSDictionary = data.value as! NSDictionary
                let key = data.key
                let post = Search(userKey: key as! String, postData: postDict as! Dictionary<String, AnyObject>, usersPreviousMessages: usersPreviousMessages)
                self.searchDetail.append(post)
            }
            
        })
 
         self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destionViewController = segue.destination as? MessageVC{
            
            destionViewController.recipient = recipient
            destionViewController.messageId = messageId
            destionViewController.members = members
            print("Line 95 GROUP NAME")
            print(groupName)
            destionViewController.groupName = groupName
        
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return filteredDate.count
        }else{
            return searchDetail.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchData: Search!
        
        if isSearching{
            searchData = filteredDate[indexPath.row]
        }else{
            searchData = searchDetail[indexPath.row]
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? searchCell{
            cell.configCell(searchDetail: searchData)
            return cell
        }
        else{
            return searchCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipient = ""
        if isSearching {
            recipient = filteredDate[indexPath.row].userKey
            members = filteredDate[indexPath.row]._members
            groupName = filteredDate[indexPath.row]._groupName
            messageId = filteredDate[indexPath.row]._previousMessageId
        }else{
            recipient = searchDetail[indexPath.row].userKey
            members = searchDetail[indexPath.row]._members
            groupName = searchDetail[indexPath.row]._groupName
            messageId = searchDetail[indexPath.row]._previousMessageId
            print("LINE 172 GroupName")
            print(groupName)
        }
        
        

        
        performSegue(withIdentifier: "toMessage", sender: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchTest: String){
        if searchBar.text == nil || searchBar.text == ""{
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }else{
            isSearching = true
            filteredDate = searchDetail.filter({$0.username == searchBar.text!})
            tableView.reloadData()
        }
    }
    
    @IBAction func goBack(_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }
}
