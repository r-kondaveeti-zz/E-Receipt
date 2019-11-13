//
//  Receipt.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/7/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation

class Receipt {
    
    var userName: String
    var managerName: String
    var imageLocation: String
    var totalCost: String
    var status: String
    
    init(userName: String, managerName: String, imageLocation: String, totalCost: String, status: String) {
        self.imageLocation = imageLocation
        self.totalCost = totalCost
        self.userName = userName
        self.managerName = managerName
        self.status = status
    }
    
}
