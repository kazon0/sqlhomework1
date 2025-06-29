//
//  FollowupTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import Foundation
import SQLite3

class FollowupTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS Followups(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        PatientId INTEGER,
        FollowupDate TEXT,
        SymptomScore INTEGER,
        DrugReaction TEXT,
        DoctorFeedback TEXT,
        FOREIGN KEY(PatientId) REFERENCES Patients(Id));
        """
        executeSQL(sql, successMessage: "随访记录表创建成功")
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

    func insertFollowup(patientId: Int32, followupDate: String, symptomScore: Int32, drugReaction: String, doctorFeedback: String) {
        let sql = "INSERT INTO Followups (PatientId, FollowupDate, SymptomScore, DrugReaction, DoctorFeedback) VALUES (?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (followupDate as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 3, symptomScore)
            sqlite3_bind_text(stmt, 4, (drugReaction as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (doctorFeedback as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("插入随访记录成功")
            } else {
                print("插入随访记录失败")
            }
        } else {
            print("插入语句准备失败")
        }
        sqlite3_finalize(stmt)
    }
    
    func queryFollowups(for patientId: Int32) -> [Followup] {
        var results: [Followup] = []
        let query = "SELECT * FROM Followups WHERE PatientId = ? ORDER BY FollowupDate DESC;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let pid = sqlite3_column_int(stmt, 1)
                let date = String(cString: sqlite3_column_text(stmt, 2))
                let score = sqlite3_column_int(stmt, 3)
                let reaction = String(cString: sqlite3_column_text(stmt, 4))
                let feedback = String(cString: sqlite3_column_text(stmt, 5))

                results.append(Followup(id: id, patientId: pid, followupDate: date, symptomScore: score, drugReaction: reaction, doctorFeedback: feedback))
            }
        } else {
            print("查询随访记录失败")
        }
        sqlite3_finalize(stmt)
        return results
    }

    // 删除
    func deleteFollowup(by id: Int32) {
        let sql = "DELETE FROM Followups WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    // 更新
    func updateFollowup(id: Int32, date: String, score: Int32, reaction: String, feedback: String) {
        let sql = "UPDATE Followups SET FollowupDate = ?, SymptomScore = ?, DrugReaction = ?, DoctorFeedback = ? WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, score)
            sqlite3_bind_text(stmt, 3, (reaction as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (feedback as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 5, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

}
