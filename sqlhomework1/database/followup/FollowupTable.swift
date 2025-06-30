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
        CREATE TABLE IF NOT EXISTS Followups (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientId INTEGER,
            FollowupDate TEXT,
            SymptomScore INTEGER,
            SymptomsJson TEXT,
            DrugReactionJson TEXT,
            DoctorFeedback TEXT,
            OtherInfoJson TEXT,
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
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

    func insertFollowup(
        patientId: Int32,
        followupDate: String,
        symptomScore: Int32,
        symptomsJson: Followup.SymptomsInfo?,
        drugReactionJson: [Followup.DrugReaction]?,
        doctorFeedback: String,
        otherInfoJson: Followup.OtherInfo?
    ) -> Bool {
        let sql = """
        INSERT INTO Followups
        (PatientId, FollowupDate, SymptomScore, SymptomsJson, DrugReactionJson, DoctorFeedback, OtherInfoJson)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            // 绑定简单类型
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (followupDate as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 3, symptomScore)

            // 编码 JSON 转字符串绑定
            let symptomsData = try? JSONEncoder().encode(symptomsJson)
            let symptomsString = symptomsData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

            let drugData = try? JSONEncoder().encode(drugReactionJson)
            let drugString = drugData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

            let otherData = try? JSONEncoder().encode(otherInfoJson)
            let otherString = otherData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

            sqlite3_bind_text(stmt, 4, (symptomsString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (drugString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (doctorFeedback as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (otherString as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入随访记录成功")
                return true
            } else {
                print("插入随访记录失败")
            }
        } else {
            print("插入语句准备失败")
        }
        sqlite3_finalize(stmt)
        return false
    }

    func textColumn(_ stmt: OpaquePointer?, index: Int32) -> String {
        if let cString = sqlite3_column_text(stmt, index) {
            return String(cString: cString)
        }
        return ""
    }

    func queryFollowups(for patientId: Int32) -> [Followup] {
        var results: [Followup] = []
        let sql = "SELECT * FROM Followups WHERE PatientId = ? ORDER BY FollowupDate DESC;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let pid = sqlite3_column_int(stmt, 1)
                let date = textColumn(stmt, index: 2)
                let score = sqlite3_column_int(stmt, 3)
                let symptomsJsonRaw = textColumn(stmt, index: 4)
                let drugJsonRaw = textColumn(stmt, index: 5)
                let doctorFeedback = textColumn(stmt, index: 6)
                let otherJsonRaw = textColumn(stmt, index: 7)

                let symptomsJson = symptomsJsonRaw.isEmpty ? nil : try? JSONDecoder().decode(Followup.SymptomsInfo.self, from: Data(symptomsJsonRaw.utf8))
                let drugReactionJson = drugJsonRaw.isEmpty ? nil : try? JSONDecoder().decode([Followup.DrugReaction].self, from: Data(drugJsonRaw.utf8))
                let otherInfoJson = otherJsonRaw.isEmpty ? nil : try? JSONDecoder().decode(Followup.OtherInfo.self, from: Data(otherJsonRaw.utf8))

                results.append(Followup(
                    id: id,
                    patientId: pid,
                    followupDate: date,
                    symptomScore: score,
                    symptomsJson: symptomsJson,
                    drugReactionJson: drugReactionJson,
                    doctorFeedback: doctorFeedback,
                    otherInfoJson: otherInfoJson
                ))
            }
            sqlite3_finalize(stmt)
        } else {
            print("查询随访记录失败")
        }
        return results
    }


    func updateFollowup(
        id: Int32,
        followupDate: String,
        symptomScore: Int32,
        symptomsJson: Followup.SymptomsInfo?,
        drugReactionJson: [Followup.DrugReaction]?,
        doctorFeedback: String,
        otherInfoJson: Followup.OtherInfo?
    ) -> Bool {
        let sql = """
        UPDATE Followups SET
            FollowupDate = ?,
            SymptomScore = ?,
            SymptomsJson = ?,
            DrugReactionJson = ?,
            DoctorFeedback = ?,
            OtherInfoJson = ?
        WHERE Id = ?;
        """

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (followupDate as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, symptomScore)

            let symptomsData = try? JSONEncoder().encode(symptomsJson)
            let symptomsString = symptomsData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

            let drugData = try? JSONEncoder().encode(drugReactionJson)
            let drugString = drugData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

            let otherData = try? JSONEncoder().encode(otherInfoJson)
            let otherString = otherData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

            sqlite3_bind_text(stmt, 3, (symptomsString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (drugString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (doctorFeedback as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (otherString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, id)

            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("更新随访记录成功")
                return true
            } else {
                print("更新随访记录失败")
            }
        } else {
            print("更新语句准备失败")
        }
        sqlite3_finalize(stmt)
        return false
    }

    func deleteFollowup(by id: Int32) -> Bool {
        let sql = "DELETE FROM Followups WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("删除随访记录成功")
                sqlite3_finalize(stmt)
                return true
            } else {
                print("删除随访记录失败")
            }
        } else {
            print("删除语句准备失败")
        }
        sqlite3_finalize(stmt)
        return false
    }
}
