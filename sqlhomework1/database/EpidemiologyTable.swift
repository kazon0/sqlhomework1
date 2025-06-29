//
//  EpidemiologyTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import Foundation
import SQLite3

class EpidemiologyTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS Epidemiology(
        PatientId INTEGER PRIMARY KEY,
        Pets INTEGER,
        DustExposure INTEGER,
        FamilyHistory INTEGER,
        Smoking INTEGER,
        FOREIGN KEY(PatientId) REFERENCES Patients(Id));
        """
        executeSQL(sql, successMessage: "流行病学调查表创建成功")
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

    func insertEpidemiology(patientId: Int32, pets: Bool, dustExposure: Bool, familyHistory: Bool, smoking: Bool) {
        let sql = "INSERT OR REPLACE INTO Epidemiology (PatientId, Pets, DustExposure, FamilyHistory, Smoking) VALUES (?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_int(stmt, 2, pets ? 1 : 0)
            sqlite3_bind_int(stmt, 3, dustExposure ? 1 : 0)
            sqlite3_bind_int(stmt, 4, familyHistory ? 1 : 0)
            sqlite3_bind_int(stmt, 5, smoking ? 1 : 0)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("插入流行病学调查成功")
            } else {
                print("插入流行病学调查失败")
            }
        } else {
            print("插入语句准备失败")
        }
        sqlite3_finalize(stmt)
    }
    
    func queryEpidemiology(for patientId: Int32) -> Epidemiology? {
        let sql = "SELECT * FROM Epidemiology WHERE PatientId = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            if sqlite3_step(stmt) == SQLITE_ROW {
                let pets = sqlite3_column_int(stmt, 1) == 1
                let dustExposure = sqlite3_column_int(stmt, 2) == 1
                let familyHistory = sqlite3_column_int(stmt, 3) == 1
                let smoking = sqlite3_column_int(stmt, 4) == 1

                sqlite3_finalize(stmt)
                return Epidemiology(
                    patientId: patientId,
                    pets: pets,
                    dustExposure: dustExposure,
                    familyHistory: familyHistory,
                    smoking: smoking
                )
            }
        }

        sqlite3_finalize(stmt)
        return nil
    }

}
