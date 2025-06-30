//
//  CheckReport.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import Foundation
import SQLite3

class CheckReportsTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS CheckReports(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientId INTEGER,
            Category TEXT,
            SubType TEXT,
            CheckDate TEXT,
            ReportJson TEXT,
            Remarks TEXT,
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "检查报告表创建成功")
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

    // 插入一条检查报告
    func insertCheckReport(patientId: Int32, category: String, subType: String, checkDate: String, reportJson: String, remarks: String) {
        let sql = """
        INSERT INTO CheckReports (PatientId, Category, SubType, CheckDate, ReportJson, Remarks)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (category as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (subType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (checkDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (reportJson as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (remarks as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("插入检查报告成功")
            } else {
                print("插入检查报告失败")
            }
        } else {
            print("插入语句准备失败")
        }
        sqlite3_finalize(stmt)
    }

    // 查询指定患者所有检查报告
    func queryReports(for patientId: Int32) -> [CheckReport] {
        var result: [CheckReport] = []
        let query = "SELECT * FROM CheckReports WHERE PatientId = ? ORDER BY CheckDate DESC;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let pid = sqlite3_column_int(stmt, 1)
                let category = String(cString: sqlite3_column_text(stmt, 2))
                let subType = String(cString: sqlite3_column_text(stmt, 3))
                let checkDate = String(cString: sqlite3_column_text(stmt, 4))
                let reportJson = String(cString: sqlite3_column_text(stmt, 5))
                let remarks = String(cString: sqlite3_column_text(stmt, 6))

                result.append(CheckReport(
                    id: id,
                    patientId: pid,
                    category: category,
                    subType: subType,
                    checkDate: checkDate,
                    reportJson: reportJson,
                    remarks: remarks
                ))
            }
        } else {
            print("查询语句准备失败")
        }
        sqlite3_finalize(stmt)
        return result
    }

    // 更新检查报告
    func updateCheckReport(id: Int32, category: String, subType: String, checkDate: String, reportJson: String, remarks: String) {
        let sql = """
        UPDATE CheckReports SET
        Category = ?,
        SubType = ?,
        CheckDate = ?,
        ReportJson = ?,
        Remarks = ?
        WHERE Id = ?;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (category as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (subType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (checkDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (reportJson as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (remarks as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 6, id)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("更新检查报告成功")
            } else {
                print("更新检查报告失败")
            }
        } else {
            print("更新语句准备失败")
        }
        sqlite3_finalize(stmt)
    }

    // 删除检查报告
    func deleteCheckReport(by id: Int32) {
        let sql = "DELETE FROM CheckReports WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("删除检查报告成功")
            } else {
                print("删除检查报告失败")
            }
        } else {
            print("删除语句准备失败")
        }
        sqlite3_finalize(stmt)
    }
}
