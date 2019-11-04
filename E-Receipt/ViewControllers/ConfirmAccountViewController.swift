//
//  ConfirmAccountViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/4/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileClient

class ConfirmAccountViewController: UIViewController {
    
    var userName: String!
    @IBOutlet weak var confirmCodeTextfield: UITextField!
    @IBOutlet weak var confirmAccountButton: UIButton!
    @IBAction func didPressConfirmAccount(_ sender: Any) {
        AWSMobileClient.default().confirmSignUp(username: SignUpViewController().firstNameTextfield.text!, confirmationCode: confirmCodeTextfield.text!) { (signUpResult, error) in
            if let signUpResult = signUpResult {
                switch(signUpResult.signUpConfirmationState) {
                case .confirmed:
                    print("User is signed up and confirmed.")
                    DispatchQueue.main.async {
                        self.transitionToLogin()
                    }
                case .unconfirmed:
                    print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
                case .unknown:
                    print("Unexpected case")
                }
            } else if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    override func viewDidLoad() {
        style()
    }
    
    func style() {
        Utilities.styleTextField(confirmCodeTextfield)
        Utilities.styleFilledButton(confirmAccountButton)
    }
    
    func transitionToLogin() {
        let loginViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController
        view.window?.rootViewController = loginViewController
        view.window?.makeKeyAndVisible()
    }
}
