
//
//  File.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/11/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import FMDB

class FMDBDatabase {
    
    /*
     * @description defines completion closure for database calls
     */
    public typealias Completion = ((Bool, Error?)-> Void)
    
    public typealias ResultCompletion = ((Bool, FMResultSet?, Error?)-> Void)
    
    static let fileURL: URL = {
       return try! FileManager.default
       .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
       .appendingPathComponent("test.sqlite")
    }()
    
    /*
     * @description singleton to access the database
     */
    static let sharedDatabase:FMDatabase = {
        let database = FMDatabase(url: fileURL)
        return database
    }()
    
    /*
     * @description singleton to access a serial queue for updating the database
     */
    static let sharedQueue: FMDatabaseQueue = { return FMDatabaseQueue(path: fileURL.path)! }()
    
    static func create(completion:Completion) {
        let sqlStatement = "CREATE TABLE IF NOT EXISTS uploads (ID Integer Primary key AutoIncrement, userName Text, managerName Text, imageLocation Text, totalCost Text, status Text);"
        FMDBDatabase.update(sqlStatement: sqlStatement, completion: completion)
    }
    
    static func insert(values: [Any], completion:Completion) {
        
        /* we need to specify NULL when using VALUES for any autoincremented keys */
        let sqlStatement = "INSERT OR REPLACE INTO uploads VALUES (NULL, ?, ?, ?, ?, ?);";
        FMDBDatabase.update(sqlStatement: sqlStatement, values:values, completion: completion)
    }
    
    private static func update(sqlStatement:String, values:[Any]? = nil, completion:Completion) {
        
        sharedQueue.inDeferredTransaction { (db, rollback) in
            do {
                if !sharedDatabase.isOpen {
                    sharedDatabase.open()
                }
                try sharedDatabase.executeUpdate(sqlStatement, values: values)
                completion(true, nil)
                sharedDatabase.close()
            } catch {
                print("failed: \(error.localizedDescription)")
                completion(false, error)
                sharedDatabase.close()
            }
        }
    }
    
    static func query(on table:String, completion:ResultCompletion){
        let sqlStatement = "SELECT * FROM uploads WHERE userName = '\(table)';"
        
        sharedQueue.inDeferredTransaction { (db, rollback) in
            do {
                if !sharedDatabase.isOpen {
                    sharedDatabase.open()
                }
                let fmresult = try sharedDatabase.executeQuery(sqlStatement, values: nil)
                completion(true, fmresult, nil)
                sharedDatabase.close()
            } catch {
                rollback.pointee = true
                completion(false, nil, error)
                sharedDatabase.close()
            }
        }
    }
    
    
}
