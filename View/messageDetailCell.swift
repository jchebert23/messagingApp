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
        self.chatPreview.text = messageDetail._lastMessage
        //this grabs information from recipient to get their profile picture
        var recipientData = Database.database().reference().child("Users").child(messageDetail.recipient)
        if(messageDetail._groupName != "" && messageDetail._groupName != nil)
        {
 
        recipientData = Database.database().reference().child("Groups").child(messageDetail.recipient)
        }
        
        recipientData.observeSingleEvent(of: .value, with: {(snapshot) in
            let data  = snapshot.value as! Dictionary<String, AnyObject>
            var username = data["username"]
            if(messageDetail._groupName != "" && messageDetail._groupName != nil)
            {
                username = data["name"]
            }
            var temp = data["prof-pic"]
            if(data["prof-pic"] == nil)
            {
                temp = "https://firebasestorage.googleapis.com/v0/b/plusonetest-2143.appspot.com/o/profile-pics%2Fdbooth?alt=media&token=23b1cd0f-980a-4a4b-9038-21387a27fcf5" as AnyObject
            }

            let userImg = NSURL(string: temp as! String)

            //gotta fix this
            
            
            
            var userImgString = data["prof-pic"]
         
            if(data["prof-pic"] == nil)
            {
                userImgString = "https://firebasestorage.googleapis.com/v0/b/plusonetest-2143.appspot.com/o/profile-pics%2Fdbooth?alt=media&token=23b1cd0f-980a-4a4b-9038-21387a27fcf5" as AnyObject
            }
            self.recipientname.text = username as? String
            let ref = Storage.storage().reference(forURL: userImgString as! String)
            URLSession.shared.dataTask(with: userImg! as URL)
            ref.getData(maxSize: 2000000, completion: { (data, error) in
                //not loading image since image exceeds maximum size
                if error != nil{

                    print(error)
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
