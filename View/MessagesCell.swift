//
//  MessagesCell.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/21/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper


class MessagesCell: UITableViewCell {

    @IBOutlet weak var receivedMessageLbl: UILabel!
    @IBOutlet weak var receivedMessageView: UIView!
    @IBOutlet weak var sentMessageLbl: UILabel!
    @IBOutlet weak var sentMessageView: UIView!
    var message: Message!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configCell(message: Message){
        self.message = message
        print("currentUser")
        print(currentUser)
        print("sender")
        print(message.sender)
        print("message")
        print(message.message)
        //IMPORTANT, determines if current user sent the message or not, and from that information it puts it puts the message to the right or left of the cell
        if message.sender == currentUser{
            sentMessageView.isHidden = false
            sentMessageLbl.text = message.message
            receivedMessageLbl.text = ""
            receivedMessageLbl.isHidden = true
        }else{
            sentMessageView.isHidden = true
            sentMessageLbl.text = ""
            receivedMessageLbl.text = message.message
            receivedMessageLbl.isHidden = false
        }
    }
}
