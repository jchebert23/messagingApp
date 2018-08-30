//
//  ViewController.swift
//  Messaging App
//
//  Created by Clayton Hebert on 8/19/18.
//  Copyright © 2018 Clayton Hebert. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class LoginVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var userUid: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid"){
            performSegue(withIdentifier: "toMessages", sender: nil)
        }
    }
    
    
    @IBAction func SignIn (_ sender: AnyObject){
        //if the email and password fields have text put them in these variables
        if let email = emailField.text, let password = passwordField.text{
            Auth.auth().signIn(withEmail: email, password: password, completion:
                {(user,error) in
                
                    if error == nil {
                        self.userUid = user?.user.uid
                        KeychainWrapper.standard.set(self.userUid,forKey: "uid")
                        self.performSegue(withIdentifier: "toMessages", sender: nil)
                    }
            })
        }
    }

}

