//
//  DatabaseManager.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()

    let db: OpaquePointer?

    private init() {
        db = DatabaseManager.openDatabase()
    }

    static func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask,
                 appropriateFor: nil, create: false)
            .appendingPathComponent("clinic.sqlite")
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("数据库打开成功：\(fileURL.path)")
            return db
        } else {
            print("无法打开数据库")
            return nil
        }
    }
}
