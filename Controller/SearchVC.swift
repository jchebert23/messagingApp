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

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var searchDetail = [Search]()
    var filteredDate = [Search]()
    var isSearching = false
    var detail: Search!
    var recipient: String!
    var messageId: String!
    var debugPrint: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        Database.database().reference().child("Users").observe(.value , with: { (snapshot) in
        
            
        let value = snapshot.value as? NSDictionary
        if(self.debugPrint)
        {
            print("Line 41")
            }
                self.searchDetail.removeAll()
                if(self.debugPrint)
                {
                    print("Line 44")
                }
                for data in value!{
                    if(self.debugPrint)
                    {
                        print("Line 49")
                    }
                    let postDict: NSDictionary = data.value as! NSDictionary
                        if(self.debugPrint)
                        {
                            print("Line 54")
                        }
                        let key = data.key
                        let post = Search(userKey: key as! String, postData: postDict as! Dictionary<String, AnyObject>)
                        self.searchDetail.append(post)
                }
            
            self.tableView.reloadData()
        })
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destionViewController = segue.destination as? MessageVC {
            destionViewController.recipient = recipient
            destionViewController.messageId = messageId
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
        if isSearching {
            recipient = filteredDate[indexPath.row].userKey
        }else{
            recipient = searchDetail[indexPath.row].userKey
        }
        if(self.debugPrint)
        {
            print("Line 116")
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
