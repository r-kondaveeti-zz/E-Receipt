//
//  HistoryViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/5/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileClient

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func viewDidLoad() {
        style()
    }
    
    private func style() {
        Utilities.stylizeLabel(visibleLabel: mainLabel)
    }
}
