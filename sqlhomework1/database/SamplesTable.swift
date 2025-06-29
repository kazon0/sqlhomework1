//
//  SamplesTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import Foundation
import SQLite3

class SamplesTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS Samples(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        PatientId INTEGER,
        SampleType TEXT,
        CollectionDate TEXT,
        StorageMethod TEXT,
        SampleCode TEXT,
        FOREIGN KEY(PatientId) REFERENCES Patients(Id));
        """
        executeSQL(sql, successMessage: "样本管理表创建成功")
    }

    func executeSQL(_ sql: String, successMessage: String) {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print(successMessage)
            } else {
                print("执行失败：\(sql)")
            }
        } else {
            print("SQL 语句准备失败：\(sql)")
        }
        sqlite3_finalize(stmt)
    }

    func insertSample(patientId: Int32, sampleType: String, collectionDate: String, storageMethod: String, sampleCode: String) {
        let sql = "INSERT INTO Samples (PatientId, SampleType, CollectionDate, StorageMethod, SampleCode) VALUES (?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (sampleType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (collectionDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (storageMethod as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (sampleCode as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("插入样本成功")
            } else {
                print("插入样本失败")
            }
        } else {
            print("插入语句准备失败")
        }
        sqlite3_finalize(stmt)
    }
    
    func querySamples(for patientId: Int32) -> [Sample] {
        var result: [Sample] = []
        let query = "SELECT * FROM Samples WHERE PatientId = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let sampleType = String(cString: sqlite3_column_text(stmt, 2))
                let collectionDate = String(cString: sqlite3_column_text(stmt, 3))
                let storageMethod = String(cString: sqlite3_column_text(stmt, 4))
                let sampleCode = String(cString: sqlite3_column_text(stmt, 5))

                result.append(Sample(
                    id: id,
                    sampleType: sampleType,
                    collectionDate: collectionDate,
                    storageMethod: storageMethod,
                    sampleCode: sampleCode
                ))
            }
        }

        sqlite3_finalize(stmt)
        return result
    }

    func deleteSample(by id: Int32) {
        let sql = "DELETE FROM Samples WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("删除样本成功")
            }
        }
        sqlite3_finalize(stmt)
    }
    
    func updateSample(id: Int32, sampleType: String, collectionDate: String, storageMethod: String, sampleCode: String) {
        let sql = """
        UPDATE Samples SET
        SampleType = ?,
        CollectionDate = ?,
        StorageMethod = ?,
        SampleCode = ?
        WHERE Id = ?;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (sampleType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (collectionDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (storageMethod as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (sampleCode as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 5, id)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("更新样本成功")
            } else {
                print("更新样本失败")
            }
        } else {
            print("更新语句准备失败")
        }
        sqlite3_finalize(stmt)
    }

}
