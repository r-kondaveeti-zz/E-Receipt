//
//  ManagerViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/8/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileClient

class ManagerViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
  
    var userName: String = AWSMobileClient.default().username!
    
    override func viewWillAppear(_ animated: Bool) {
        FMDBDatabase.query(on: "radhithya99", completion: {
            (success, resultSet, error) in
            if success {
                if let fmresult = resultSet {
                    while fmresult.next() {
                        let row = fmresult.int(forColumn: "ID")
                        let userName = fmresult.string(forColumn: "userName")
                        let imageLocation = fmresult.string(forColumn: "imageLocation")
                        self.load(fileName: imageLocation!)
                        let cost = fmresult.string(forColumn: "totalCost")
                        self.userNameLabel.text = cost
                        print(userName!)
                        print(row)
                        print(imageLocation!)
                        print(cost!)
                    }
                }
            }
        })
        
    }
    override func viewDidLoad() {
        style()
    }
    
    private func style() {
        Utilities.stylizeLabel(visibleLabel: mainLabel)
    }
    
    private func load(fileName: String) -> UIImage? {
        print("Trying to load the image! ")
        let fileURL = URL(fileURLWithPath: fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }

}
