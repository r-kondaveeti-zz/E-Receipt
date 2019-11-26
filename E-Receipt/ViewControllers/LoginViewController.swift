//
//  LoginViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/3/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import UIKit
import Foundation
import AWSMobileClient

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var userName: String!
    
    @IBAction func didPressLogin(_ sender: Any) {
        view.endEditing(true)
        let error = validateFields()
        if error != nil {
            showError(error: error!)
        }
        else {
            let email = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            AWSMobileClient.default().signIn(username: email, password: password) { (signInResult, error) in
                if let error = error  {
                    self.showError(error: "Please enter valid credentials")
                    print("----> \(error.localizedDescription)")
                } else if let signInResult = signInResult {
                    switch (signInResult.signInState) {
                    case .signedIn:
                        print("User is signed in.")
                        DispatchQueue.main.async {
                            if AWSMobileClient.default().username! == "ankit99" { self.transitionToManager() } else { self.transitionToHome() }
                        }
                    case .smsMFA:
                        print("SMS message sent to \(signInResult.codeDetails!.destination!)")
                    default:
                        print("Sign In needs info which is not et supported.")
                    }
                }
            }
        }
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
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
    func validateFields() -> String? {
        if emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        let cleanedPassword = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        return nil
    }
    
    func showError(error: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = "\(error)"
        }
    }
    
    func transitionToManager() {
        let managerViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.managerViewController) as? ManagerViewController
        view.window?.rootViewController = managerViewController
        view.window?.makeKeyAndVisible()
        print("Transition to Manager.....");
    }
    
}
