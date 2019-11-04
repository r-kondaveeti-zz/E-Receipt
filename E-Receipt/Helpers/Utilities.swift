//
//  Utility.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/3/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 33/255, green: 140/255, blue: 116/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 33/255, green: 140/255, blue: 116/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    //Used for rounding and shadowing buttons
    static func stylizeButtonAndShadow(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width: -5, height: 5)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4.0
    }
    
    //Used for rounding labels and shadows
    static func stylizeLabelAndShadow(visibleLabel: UILabel, shadowLabel: UILabel) {
        visibleLabel.layer.cornerRadius = 10
        visibleLabel.layer.masksToBounds = true
        shadowLabel.layer.cornerRadius = 10
        shadowLabel.layer.masksToBounds = false
        shadowLabel.layer.shadowColor = UIColor.lightGray.cgColor
        shadowLabel.layer.shadowOffset = CGSize(width: -5, height: 5)
        shadowLabel.layer.shadowOpacity = 45
        shadowLabel.layer.shadowRadius = 4.0
    }
    
    //Stylizes main label
    static func stylizeLabel(visibleLabel: UILabel) {
        visibleLabel.layer.shadowColor = UIColor.lightGray.cgColor
        visibleLabel.layer.shadowOffset = CGSize(width: -5, height: 5)
        visibleLabel.layer.shadowOpacity = 0.5
        visibleLabel.layer.shadowRadius = 4.0
    }
    
}

