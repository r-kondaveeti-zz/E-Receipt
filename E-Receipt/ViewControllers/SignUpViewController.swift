//
//  SignUpViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/3/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileClient

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func didPressSignUp(_ sender: Any) {
        view.endEditing(true)
        let error = validateFields()
        if error != nil {
            showError(error!)
        }
        else {
            // Create cleaned versions of the data
            let firstName = firstNameTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            AWSMobileClient.default().signUp(username: firstName,
                                                    password: password,
                                                    userAttributes: ["email": email, "phone_number": "+1973123456"]) { (signUpResult, error) in
                if let signUpResult = signUpResult {
                    switch(signUpResult.signUpConfirmationState) {
                    case .confirmed:
                        print("User is signed up and confirmed.")
                    case .unconfirmed:
                        print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
                        DispatchQueue.main.async {
                            self.transitionToConfirmAccount()
                        }
                    case .unknown:
                        print("Unexpected case")
                    }
                } else if let error = error {
                    if let error = error as? AWSMobileClientError {
                        switch(error) {
                        case .usernameExists(let message):
                            print(message)
                        default:
                            break
                        }
                    }
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToConfirmAccount() {
        let confirmAccountViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.confirmAccountViewController) as? ConfirmAccountViewController
        view.window?.rootViewController = confirmAccountViewController
        view.window?.makeKeyAndVisible()
    }
    
    override func viewDidLoad() {
        setUpElements()
    }
    
    // Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
    func validateFields() -> String? {
        if firstNameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        let cleanedPassword = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        return nil
    }
   
    func setUpElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(firstNameTextfield)
        Utilities.styleTextField(lastNameTextfield)
        Utilities.styleTextField(emailTextfield)
        Utilities.styleTextField(passwordTextfield)
        Utilities.styleFilledButton(signUpButton)
    }
}
