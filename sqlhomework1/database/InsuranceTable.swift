//
//  InsuranceTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import Foundation
import SQLite3

class InsuranceTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS Insurance(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        PatientId INTEGER,
        InsuranceType TEXT,
        InsuranceNumber TEXT,
        CoverageScope TEXT,
        ValidFrom TEXT,
        ValidTo TEXT,
        Remarks TEXT,
        FOREIGN KEY(PatientId) REFERENCES Patients(Id));
        """
        executeSQL(sql, successMessage: "医保信息表创建成功")
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

    func insertInsurance(patientId: Int32, insuranceType: String, insuranceNumber: String, coverageScope: String, validFrom: String, validTo: String, remarks: String) {
        let sql = "INSERT INTO Insurance (PatientId, InsuranceType, InsuranceNumber, CoverageScope, ValidFrom, ValidTo, Remarks) VALUES (?, ?, ?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (insuranceType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (insuranceNumber as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (coverageScope as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (validFrom as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (validTo as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (remarks as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("插入医保信息成功")
            } else {
                print("插入医保信息失败")
            }
        } else {
            print("插入语句准备失败")
        }
        sqlite3_finalize(stmt)
    }

    func queryInsurance(for patientId: Int32) -> [Insurance] {
        var result: [Insurance] = []
        let query = "SELECT * FROM Insurance WHERE PatientId = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let insuranceType = String(cString: sqlite3_column_text(stmt, 2))
                let insuranceNumber = String(cString: sqlite3_column_text(stmt, 3))
                let coverageScope = String(cString: sqlite3_column_text(stmt, 4))
                let validFrom = String(cString: sqlite3_column_text(stmt, 5))
                let validTo = String(cString: sqlite3_column_text(stmt, 6))
                let remarks = String(cString: sqlite3_column_text(stmt, 7))

                result.append(Insurance(
                    id: id,
                    patientId: patientId,
                    insuranceType: insuranceType,
                    insuranceNumber: insuranceNumber,
                    coverageScope: coverageScope,
                    validFrom: validFrom,
                    validTo: validTo,
                    remarks: remarks
                ))
            }
        }

        sqlite3_finalize(stmt)
        return result
    }

    func deleteInsurance(by id: Int32) {
        let sql = "DELETE FROM Insurance WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("删除医保信息成功")
            }
        }
        sqlite3_finalize(stmt)
    }

    func updateInsurance(id: Int32, insuranceType: String, insuranceNumber: String, coverageScope: String, validFrom: String, validTo: String, remarks: String) {
        let sql = """
        UPDATE Insurance SET
        InsuranceType = ?,
        InsuranceNumber = ?,
        CoverageScope = ?,
        ValidFrom = ?,
        ValidTo = ?,
        Remarks = ?
        WHERE Id = ?;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (insuranceType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (insuranceNumber as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (coverageScope as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (validFrom as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (validTo as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (remarks as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, id)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("更新医保信息成功")
            } else {
                print("更新医保信息失败")
            }
        } else {
            print("更新语句准备失败")
        }
        sqlite3_finalize(stmt)
    }
}
