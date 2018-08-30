//
//  messageDetailCell.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/20/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper

class messageDetailCell: UITableViewCell {

    @IBOutlet weak var recipientImg: UIImageView!
    @IBOutlet weak var recipientname: UILabel!
    @IBOutlet weak var chatPreview: UILabel!
    
    var messageDetail: MessageDetail!
    
    var userPostKey: DatabaseReference!
    
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(messageDetail: MessageDetail){
        self.messageDetail = messageDetail
        let recipientData = Database.database().reference().child("users").child(messageDetail.recipient)
        recipientData.observeSingleEvent(of: .value, with: {(snapshot) in
            
            let data  = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            let userImg = data["userImg"]
            self.recipientname.text = username as? String
            let ref = Storage.storage().reference(forURL: userImg as! String)
            URLSession.shared.dataTask(with: userImg as! URL)
            ref.getData(maxSize: 100000, completion: { (data, error) in
                
                if error != nil{
                    print("could not load image")
                } else{
                    if let imgData = data {
                        if let img = data {
                            if let img = UIImage(data: imgData){
                                self.recipientImg.image = img
                            }
                        }
                    }
                }
            })
        })
    }
    
}
