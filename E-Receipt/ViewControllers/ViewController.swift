//
//  ViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/3/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        setUpElements()
    }
    
    func setUpElements() {
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signUpButton)
    }
    
}
