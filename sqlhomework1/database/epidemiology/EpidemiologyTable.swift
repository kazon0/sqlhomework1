//
//  EpidemiologyTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//

import Foundation
import SQLite3

class EpidemiologyMainTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS EpidemiologyMain (
            PatientId INTEGER PRIMARY KEY,
            InvestigationDate TEXT,
            PatientName TEXT,
            Gender TEXT,
            Age INTEGER,
            ResidenceType TEXT,
            ResidenceYears INTEGER,
            Address TEXT,
            Height REAL,
            Weight REAL,
            HasAllergyHistory INTEGER,
            AllergyDiseases TEXT,
            CurrentDiagnoses TEXT,
            InvestigatorName TEXT,
            InvestigatorTitle TEXT,
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "流行病学主表创建成功")
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

    func insertOrUpdate(
        patientId: Int32,
        investigationDate: String,
        patientName: String,
        gender: String,
        age: Int,
        residenceType: String,
        residenceYears: Int,
        address: String,
        height: Double,
        weight: Double,
        hasAllergyHistory: Bool,
        allergyDiseases: String,  // 多个疾病用逗号分隔
        currentDiagnoses: String, // 多个疾病用逗号分隔
        investigatorName: String,
        investigatorTitle: String
    ) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO EpidemiologyMain (
            PatientId, InvestigationDate, PatientName, Gender, Age,
            ResidenceType, ResidenceYears, Address, Height, Weight,
            HasAllergyHistory, AllergyDiseases, CurrentDiagnoses,
            InvestigatorName, InvestigatorTitle
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (investigationDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (patientName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (gender as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 5, Int32(age))
            sqlite3_bind_text(stmt, 6, (residenceType as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, Int32(residenceYears))
            sqlite3_bind_text(stmt, 8, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 9, height)
            sqlite3_bind_double(stmt, 10, weight)
            sqlite3_bind_int(stmt, 11, hasAllergyHistory ? 1 : 0)
            sqlite3_bind_text(stmt, 12, (allergyDiseases as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 13, (currentDiagnoses as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 14, (investigatorName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 15, (investigatorTitle as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入/更新流行病学主信息成功")
                return true
            }
        }
        sqlite3_finalize(stmt)
        print("插入/更新流行病学主信息失败")
        return false
    }

    func query(patientId: Int32) -> (
        investigationDate: String,
        patientName: String,
        gender: String,
        age: Int,
        residenceType: String,
        residenceYears: Int,
        address: String,
        height: Double,
        weight: Double,
        hasAllergyHistory: Bool,
        allergyDiseases: String,
        currentDiagnoses: String,
        investigatorName: String,
        investigatorTitle: String
    )? {
        let sql = """
        SELECT InvestigationDate, PatientName, Gender, Age, ResidenceType,
            ResidenceYears, Address, Height, Weight, HasAllergyHistory,
            AllergyDiseases, CurrentDiagnoses, InvestigatorName, InvestigatorTitle
        FROM EpidemiologyMain WHERE PatientId = ?;
        """
        var stmt: OpaquePointer?
        var result: (
            String, String, String, Int, String,
            Int, String, Double, Double, Bool,
            String, String, String, String
        )?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            if sqlite3_step(stmt) == SQLITE_ROW {
                let investigationDate = String(cString: sqlite3_column_text(stmt, 0))
                let patientName = String(cString: sqlite3_column_text(stmt, 1))
                let gender = String(cString: sqlite3_column_text(stmt, 2))
                let age = Int(sqlite3_column_int(stmt, 3))
                let residenceType = String(cString: sqlite3_column_text(stmt, 4))
                let residenceYears = Int(sqlite3_column_int(stmt, 5))
                let address = String(cString: sqlite3_column_text(stmt, 6))
                let height = sqlite3_column_double(stmt, 7)
                let weight = sqlite3_column_double(stmt, 8)
                let hasAllergyHistory = sqlite3_column_int(stmt, 9) == 1
                let allergyDiseases = String(cString: sqlite3_column_text(stmt, 10))
                let currentDiagnoses = String(cString: sqlite3_column_text(stmt, 11))
                let investigatorName = String(cString: sqlite3_column_text(stmt, 12))
                let investigatorTitle = String(cString: sqlite3_column_text(stmt, 13))

                result = (
                    investigationDate, patientName, gender, age, residenceType,
                    residenceYears, address, height, weight, hasAllergyHistory,
                    allergyDiseases, currentDiagnoses, investigatorName, investigatorTitle
                )
            }
        }
        sqlite3_finalize(stmt)
        return result
    }
}
