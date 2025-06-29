//
//  PatientTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import Foundation
import SQLite3

class PatientTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        guard let db = db else {
            fatalError("数据库未打开，PatientTable初始化失败")
        }
        self.db = db
        createTable()
    }


    func createTable() {
        guard let db = db else {
            print("数据库未打开，无法创建表")
            return
        }
        let sql = """
        CREATE TABLE IF NOT EXISTS Patients(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT,
        Gender TEXT,
        Birthdate TEXT,
        Phone TEXT,
        Status TEXT DEFAULT '在诊中');
        """
        executeSQL(sql, successMessage: "患者表创建成功", db: db)
    }

    func executeSQL(_ sql: String, successMessage: String, db: OpaquePointer) {
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


    func insertPatient(name: String, gender: String, birthdate: String, phone: String, status: String = "在诊中") {
        let sql = "INSERT INTO Patients (Name, Gender, Birthdate, Phone, Status) VALUES (?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (gender as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (birthdate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (status as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("插入患者成功")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("插入患者失败，错误信息: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("插入语句准备失败，错误信息: \(errmsg)")
        }
        sqlite3_finalize(stmt)
    }

    func queryAllPatients() -> [Patient] {
        var result: [Patient] = []
        let query = "SELECT * FROM Patients;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let gender = String(cString: sqlite3_column_text(stmt, 2))
                let birthdate = String(cString: sqlite3_column_text(stmt, 3))
                let phone = String(cString: sqlite3_column_text(stmt, 4))
                let status = sqlite3_column_text(stmt, 5).flatMap { String(cString: $0) } ?? "未知状态"

                result.append(Patient(id: id, name: name, gender: gender, birthdate: birthdate, phone: phone, status: status))
            }
        } else {
            print("查询语句准备失败")
        }

        sqlite3_finalize(stmt)
        return result
    }
    
    func deletePatient(by id: Int32) {
        let sql = "DELETE FROM Patients WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("删除患者成功")
            } else {
                print("删除失败")
            }
        } else {
            print("删除语句准备失败")
        }
        sqlite3_finalize(stmt)
    }

    func updatePatientStatus(id: Int32, status: String) {
        let sql = "UPDATE Patients SET Status = ? WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (status as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("更新患者状态成功")
            } else {
                print("更新患者状态失败")
            }
        } else {
            print("更新状态语句准备失败")
        }
        sqlite3_finalize(stmt)
    }
    
    func updatePatientInfo(id: Int32, name: String, gender: String, birthdate: String, phone: String, status: String) {
        let sql = """
        UPDATE Patients SET Name = ?, Gender = ?, Birthdate = ?, Phone = ?, Status = ? WHERE Id = ?;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (gender as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (birthdate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (status as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 6, id)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("患者信息更新成功")
            } else {
                print("更新失败")
            }
        } else {
            print("准备更新语句失败")
        }
        sqlite3_finalize(stmt)
    }

}
