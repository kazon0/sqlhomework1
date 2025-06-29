//
//  DiagnosisTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import Foundation
import SQLite3

class DiagnosisTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS Diagnoses(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        PatientId INTEGER,
        Diagnosis TEXT,
        VisitDate TEXT,
        Allergens TEXT,
        Treatment TEXT,
        FOREIGN KEY(PatientId) REFERENCES Patients(Id));
        """
        executeSQL(sql, successMessage: "临床诊断表创建成功")
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

    func insertDiagnosis(patientId: Int32, diagnosis: String, visitDate: String, allergens: String, treatment: String) {
        let sql = "INSERT INTO Diagnoses (PatientId, Diagnosis, VisitDate, Allergens, Treatment) VALUES (?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (diagnosis as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (visitDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (allergens as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (treatment as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("插入诊断成功")
            } else {
                print("插入诊断失败")
            }
        } else {
            print("插入语句准备失败")
        }
        sqlite3_finalize(stmt)
    }
    
    func queryDiagnoses(for patientId: Int32) -> [Diagnosis] {
        var result: [Diagnosis] = []
        let query = "SELECT * FROM Diagnoses WHERE PatientId = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let patientId = sqlite3_column_int(stmt, 1)
                let diagnosis = String(cString: sqlite3_column_text(stmt, 2))
                let visitDate = String(cString: sqlite3_column_text(stmt, 3))
                let allergens = String(cString: sqlite3_column_text(stmt, 4))
                let treatment = String(cString: sqlite3_column_text(stmt, 5))

                result.append(Diagnosis(id: id, patientId: patientId, diagnosis: diagnosis, visitDate: visitDate, allergens: allergens, treatment: treatment))
            }
        } else {
            print("查询诊断记录失败")
        }

        sqlite3_finalize(stmt)
        return result
    }
    
    func deleteDiagnosis(by id: Int32) {
        let sql = "DELETE FROM Diagnoses WHERE Id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("删除诊断记录成功")
            } else {
                print("删除诊断记录失败")
            }
        } else {
            print("删除语句准备失败")
        }

        sqlite3_finalize(stmt)
    }
    
    func updateDiagnosis(id: Int32, diagnosis: String, visitDate: String, allergens: String, treatment: String) {
        let sql = "UPDATE Diagnoses SET Diagnosis = ?, VisitDate = ?, Allergens = ?, Treatment = ? WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (diagnosis as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (visitDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (allergens as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (treatment as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 5, id)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("更新诊断成功")
            } else {
                print("更新诊断失败")
            }
        } else {
            print("更新语句准备失败")
        }
        sqlite3_finalize(stmt)
    }

}
