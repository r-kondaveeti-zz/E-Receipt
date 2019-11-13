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
//                FMDBDatabase.create(completion: { (success, error) in
//                    if success { print("table created!")}
//                })
////                let values: [String] = ["Angelique", "Ankit", "/use/something", "$1", "pending"]
////                FMDBDatabase.insert(values: values, completion: {
////                    (success, error) in
////                    if success { print("values inserted!") }
////                })
//        FMDBDatabase.query(on: "radhithya99", completion: {
//            (success, resultSet, error) in
//            if success {
//                if let fmresult = resultSet {
//                    while fmresult.next() {
//                        let row = fmresult.int(forColumn: "ID")
//                        let userName = fmresult.string(forColumn: "userName")
//                        let imageLocation = fmresult.string(forColumn: "imageLocation")
//                        let cost = fmresult.string(forColumn: "totalCost")
//                        print(userName!)
//                        print(row)
//                        print(imageLocation!)
//                        print(cost!)
//                    }
//                }
//            }
//        })
    }
    
    func setUpElements() {
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signUpButton)
    }
    
}
