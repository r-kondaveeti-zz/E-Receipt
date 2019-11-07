//
//  NavigationController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/3/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    override func viewWillAppear(_ animated: Bool) {
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLoad() { self.navigationController?.navigationBar.shadowImage = UIImage() }
    
    @objc func back() { self.dismiss(animated: true, completion: nil) }
}
