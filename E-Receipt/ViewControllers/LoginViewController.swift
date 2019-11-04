//
//  LoginViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/3/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func didPressLogin(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        setUpElements()
    }
    
    func setUpElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextfield)
        Utilities.styleTextField(passwordTextfield)
        Utilities.styleFilledButton(loginButton)
    }
}
