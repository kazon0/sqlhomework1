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
        CREATE TABLE IF NOT EXISTS Diagnoses (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientId INTEGER,
            VisitDate TEXT,
            DiseaseType TEXT,      -- 哮喘、鼻炎、湿疹、其他
            CustomName TEXT,       -- 仅 DiseaseType == 其他 时填写
            Allergens TEXT,
            Treatment TEXT,
            SymptomJson TEXT,      -- 存储症状 JSON 字符串
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
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

    func insertDiagnosis(patientId: Int32, visitDate: String, diseaseType: String, customName: String?, allergens: String, treatment: String, symptomJson: String) {
        let sql = """
        INSERT INTO Diagnoses (PatientId, VisitDate, DiseaseType, CustomName, Allergens, Treatment, SymptomJson)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (visitDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (diseaseType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, NSString(string: customName ?? "").utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (allergens as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (treatment as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (symptomJson as NSString).utf8String, -1, nil)

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
                let visitDate = String(cString: sqlite3_column_text(stmt, 2))
                let diseaseType = String(cString: sqlite3_column_text(stmt, 3))
                let customName = String(cString: sqlite3_column_text(stmt, 4))
                let allergens = String(cString: sqlite3_column_text(stmt, 5))
                let treatment = String(cString: sqlite3_column_text(stmt, 6))
                let symptomJson = String(cString: sqlite3_column_text(stmt, 7))

                result.append(Diagnosis(
                    id: id,
                    patientId: patientId,
                    diseaseType: diseaseType,
                    customName: customName,
                    visitDate: visitDate,
                    allergens: allergens,
                    treatment: treatment,
                    symptomJson: symptomJson
                ))
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
    
    func updateDiagnosis(id: Int32, diseaseType: String, customName: String?, visitDate: String, allergens: String, treatment: String, symptomJson: String) {
        let sql = """
        UPDATE Diagnoses SET
            DiseaseType = ?,
            CustomName = ?,
            VisitDate = ?,
            Allergens = ?,
            Treatment = ?,
            SymptomJson = ?
        WHERE Id = ?;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (diseaseType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, NSString(string: customName ?? "").utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (visitDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (allergens as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (treatment as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (symptomJson as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, id)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("更新诊断成功")
            } else {
                print("更新诊断失败: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("更新语句准备失败")
        }
        sqlite3_finalize(stmt)
    }

}
