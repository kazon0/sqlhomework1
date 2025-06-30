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
            VisitDate TEXT NOT NULL,
            Name TEXT NOT NULL,
            Gender TEXT,
            BirthDate TEXT,
            Age INTEGER,
            Address TEXT,
            Height REAL,
            Weight REAL,
            BirthWeight REAL,
            Lifestyle TEXT,
            Phone TEXT,
            Status TEXT DEFAULT '在诊中'
        );
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

    func insertPatient(
        visitDate: String,
        name: String,
        gender: String,
        birthDate: String,
        age: Int,
        address: String,
        height: Double,
        weight: Double,
        birthWeight: Double,
        lifestyle: String,
        phone: String,
        status: String = "在诊中"
    ) {
        let sql = """
        INSERT INTO Patients (VisitDate, Name, Gender, BirthDate, Age, Address, Height, Weight, BirthWeight, Lifestyle, Phone, Status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (visitDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (gender as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (birthDate as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 5, Int32(age))
            sqlite3_bind_text(stmt, 6, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 7, height)
            sqlite3_bind_double(stmt, 8, weight)
            sqlite3_bind_double(stmt, 9, birthWeight)
            sqlite3_bind_text(stmt, 10, (lifestyle as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 11, (phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 12, (status as NSString).utf8String, -1, nil)

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
                let visitDate = String(cString: sqlite3_column_text(stmt, 1))
                let name = String(cString: sqlite3_column_text(stmt, 2))
                let gender = String(cString: sqlite3_column_text(stmt, 3))
                let birthDate = String(cString: sqlite3_column_text(stmt, 4))
                let age = Int(sqlite3_column_int(stmt, 5))
                let address = sqlite3_column_text(stmt, 6).map { String(cString: $0) } ?? ""
                let height = sqlite3_column_double(stmt, 7)
                let weight = sqlite3_column_double(stmt, 8)
                let birthWeight = sqlite3_column_double(stmt, 9)
                let lifestyle = String(cString: sqlite3_column_text(stmt, 10))
                let phone = String(cString: sqlite3_column_text(stmt, 11))
                let status = String(cString: sqlite3_column_text(stmt, 12))

                result.append(Patient(
                    id: id,
                    visitDate: visitDate,
                    name: name,
                    gender: gender,
                    birthDate: birthDate,
                    age: age,
                    address: address,
                    height: height,
                    weight: weight,
                    birthWeight: birthWeight,
                    lifestyle: lifestyle,
                    phone: phone,
                    status: status
                ))
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

    func updatePatientInfo(
        id: Int32,
        visitDate: String,
        name: String,
        gender: String,
        birthDate: String,
        age: Int,
        address: String,
        height: Double,
        weight: Double,
        birthWeight: Double,
        lifestyle: String,
        phone: String,
        status: String
    ) {
        let sql = """
        UPDATE Patients SET VisitDate = ?, Name = ?, Gender = ?, BirthDate = ?, Age = ?, Address = ?, Height = ?, Weight = ?, BirthWeight = ?, Lifestyle = ?, Phone = ?, Status = ? WHERE Id = ?;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (visitDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (gender as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (birthDate as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 5, Int32(age))
            sqlite3_bind_text(stmt, 6, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 7, height)
            sqlite3_bind_double(stmt, 8, weight)
            sqlite3_bind_double(stmt, 9, birthWeight)
            sqlite3_bind_text(stmt, 10, (lifestyle as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 11, (phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 12, (status as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 13, id)

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
