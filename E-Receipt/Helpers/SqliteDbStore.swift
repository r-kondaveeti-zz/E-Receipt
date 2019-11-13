//
//  SqliteDbStore.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 11/7/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import Foundation
import SQLite3

class SqliteDbStore {
    
    var db: OpaquePointer?
    var fileUrl: URL!
    var readEntryStmt: OpaquePointer?
    var insertEntryStmt: OpaquePointer?
    
    //MARK: Open db
    func openDb() {
        
        do {
            
            fileUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("test.sqlite")
        }
        catch {
            print("Error occured")
            return
        }
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("Error has occured in opening the database connection")
            return
        }
        
        let createQuery  = "CREATE TABLE IF NOT EXISTS Receipts (id INTEGER PRIMARY KEY AUTOINCREMENT, ImageLocation TEXT, TotalCost TEXT, UserName TEXT, ManagerName TEXT, Status TEXT)"
        
        if sqlite3_exec(db, createQuery, nil, nil, nil) != SQLITE_OK {
            print("Error occured in creating table")
            return
        }
        print("Tabled created")
    }
    
    func insertValues(imageLocation: String, totalCost: String, userName: String, managerName: String, status: String) {
        var stmt: OpaquePointer?
        let insertQuery = "INSERT INTO Receipts (ImageLocation, TotalCost, UserName, ManagerName, Status) VALUES (?,?,?,?,?)"
        if sqlite3_prepare(db, insertQuery, -1, &stmt,  nil) != SQLITE_OK {
            print("Error binding query")
        }
        
        sqlite3_bind_text(stmt, 1, imageLocation, -1, nil)
        sqlite3_bind_text(stmt, 2, totalCost, -1, nil)
        sqlite3_bind_text(stmt, 3, userName, -1, nil)
        sqlite3_bind_text(stmt, 4, managerName, -1, nil)
        sqlite3_bind_text(stmt, 5, status, -1, nil)
        
        sqlite3_step(stmt)
    }
    
//    //MARK: Read from the db
//    //"SELECT * FROM Records WHERE EmployeeID = ? LIMIT 1"
//    func read(id: String) {
//        // ensure statements are created on first usage if nil
//        if self.prepareReadEntryStmt() != SQLITE_OK { print("Error in preparing the statement")
//        }
//
//        defer {
//            // reset the prepared statement on exit.
//            sqlite3_reset(self.readEntryStmt)
//        }
//
//        //Inserting employeeID in readEntryStmt prepared statement
//        if sqlite3_bind_text(self.readEntryStmt, 1, (id as NSString).utf8String, -1, nil) != SQLITE_OK {
//            print("Error in binding value")
//        }
//
//        //executing the query to read value
//        if sqlite3_step(readEntryStmt) != SQLITE_ROW {
//            print("Error in executing read statement")
//        }
//
////
////        return Receipt(imageLocation: String(cString: sqlite3_column_text(readEntryStmt, 1)),
////                      totalCost: String(cString: sqlite3_column_text(readEntryStmt, 2)),
////                      userName: String(cString: sqlite3_column_text(readEntryStmt, 3)), managerName: String(cString: sqlite3_column_text(readEntryStmt, 4)), status: String(cString: sqlite3_column_text(readEntryStmt, 5)))
//    }
//
//    //MARK: Create record method
//    func create(record: Receipt) {
//        // ensure statements are created on first usage if nil
//        guard self.prepareInsertEntryStmt() == SQLITE_OK else { return }
//
//        defer {
//            // reset the prepared statement on exit.
//            sqlite3_reset(self.insertEntryStmt)
//        }
//
//        //Inserting name in insertEntryStmt prepared statement
//        if sqlite3_bind_text(self.insertEntryStmt, 1, (record.imageLocation as NSString).utf8String, -1, nil) != SQLITE_OK {
//            return
//        }
//
//        //Inserting employeeID in insertEntryStmt prepared statement
//        if sqlite3_bind_text(self.insertEntryStmt, 2, (record.totalCost as NSString).utf8String, -1, nil) != SQLITE_OK {
//            return
//        }
//
//        //Inserting designation in insertEntryStmt prepared statement
//        if sqlite3_bind_text(self.insertEntryStmt, 3, (record.userName as NSString).utf8String, -1, nil) != SQLITE_OK {
//            return
//        }
//
//        //Inserting designation in insertEntryStmt prepared statement
//        if sqlite3_bind_text(self.insertEntryStmt, 3, (record.managerName as NSString).utf8String, -1, nil) != SQLITE_OK {
//            return
//        }
//
//        //Inserting designation in insertEntryStmt prepared statement
//        if sqlite3_bind_text(self.insertEntryStmt, 3, (record.status as NSString).utf8String, -1, nil) != SQLITE_OK {
//            return
//        }
//
//        //executing the query to insert values
//        let r = sqlite3_step(self.insertEntryStmt)
//        if r != SQLITE_DONE {
//            return
//        }
//    }
//
//
//    //MARK: Prepared statement functions for every operation!
//    // READ operation prepared statement
//    func prepareReadEntryStmt() -> Int32 {
//        guard readEntryStmt == nil else { return SQLITE_OK }
//        let sql = "SELECT * FROM Receipts WHERE id = ? LIMIT 1"
//        //preparing the query
//        let r = sqlite3_prepare(db, sql, -1, &readEntryStmt, nil)
//        if  r != SQLITE_OK {
//        }
//        return r
//    }
//
//    // INSERT/CREATE operation prepared statement
//    func prepareInsertEntryStmt() -> Int32 {
//        guard insertEntryStmt == nil else { return SQLITE_OK }
//        let sql = "INSERT INTO Receipts (ImageLocation, TotalCost, UserName, ManagerName, Status) VALUES (?,?,?,?,?)"
//        //preparing the query
//        let r = sqlite3_prepare(db, sql, -1, &insertEntryStmt, nil)
//        if  r != SQLITE_OK {
//        }
//        return r
//    }
    
}
