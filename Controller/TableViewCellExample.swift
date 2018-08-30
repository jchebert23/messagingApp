//
//  TableViewCellExample.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/25/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import UIKit

class TableViewCellExample: UITableViewCell {

    @IBOutlet weak var recipientView: UIImageView!
    
    @IBOutlet weak var recipientLabel: UILabel!
    
    @IBOutlet weak var userView: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(_ recipientView2: String, userView2: String, recipientLabel2: String, userLabel2: String){
        recipientView.image = UIImage(named: recipientView2)
        recipientLabel.text = recipientLabel2
        userView.image = UIImage(named: userView2)
        userLabel.text = userLabel2
    }
    
}
