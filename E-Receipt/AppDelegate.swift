//
//  AppDelegate.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 10/23/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import UIKit
import AWSCognito
import AWSCore
import AWSTextract

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let identityID =  "us-east-1:04726819-dd85-47f8-831d-0563035c42a8"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: identityID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSTextract.register(with: configuration!, forKey: "USEast1Textract")
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

