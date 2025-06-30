//
//  StudyWorkEnvironmentTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//


import Foundation
import SQLite3

class StudyWorkEnvironmentTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS StudyWorkEnvironment (
            PatientId INTEGER PRIMARY KEY,
            Location TEXT,
            Ventilation TEXT,
            PM25_AnnualAverage REAL,
            Pollen_PeakConcentration REAL,
            Pollen_Types TEXT,
            Formaldehyde_Level REAL,
            DustMite_Exposure INTEGER,
            FabricFurniture_Use INTEGER,
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "学习/工作环境表创建成功")
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
        location: String,
        ventilation: String,
        pm25AnnualAverage: Double,
        pollenPeakConcentration: Double,
        pollenTypes: String,
        formaldehydeLevel: Double,
        dustMiteExposure: Bool,
        fabricFurnitureUse: Bool
    ) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO StudyWorkEnvironment (
            PatientId, Location, Ventilation, PM25_AnnualAverage,
            Pollen_PeakConcentration, Pollen_Types, Formaldehyde_Level,
            DustMite_Exposure, FabricFurniture_Use
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (location as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (ventilation as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 4, pm25AnnualAverage)
            sqlite3_bind_double(stmt, 5, pollenPeakConcentration)
            sqlite3_bind_text(stmt, 6, (pollenTypes as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 7, formaldehydeLevel)
            sqlite3_bind_int(stmt, 8, dustMiteExposure ? 1 : 0)
            sqlite3_bind_int(stmt, 9, fabricFurnitureUse ? 1 : 0)

            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入/更新学习工作环境成功")
                return true
            }
        }
        sqlite3_finalize(stmt)
        print("插入/更新学习工作环境失败")
        return false
    }

    func query(patientId: Int32) -> StudyWorkEnvironment? {
        let sql = "SELECT * FROM StudyWorkEnvironment WHERE PatientId = ?;"
        var stmt: OpaquePointer?
        var result: StudyWorkEnvironment?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            if sqlite3_step(stmt) == SQLITE_ROW {
                let location = String(cString: sqlite3_column_text(stmt, 1))
                let ventilation = String(cString: sqlite3_column_text(stmt, 2))
                let pm25AnnualAverage = sqlite3_column_double(stmt, 3)
                let pollenPeakConcentration = sqlite3_column_double(stmt, 4)
                let pollenTypes = String(cString: sqlite3_column_text(stmt, 5))
                let formaldehydeLevel = sqlite3_column_double(stmt, 6)
                let dustMiteExposure = sqlite3_column_int(stmt, 7) == 1
                let fabricFurnitureUse = sqlite3_column_int(stmt, 8) == 1

                result = StudyWorkEnvironment(
                    patientId: patientId,
                    location: location,
                    ventilation: ventilation,
                    pm25AnnualAverage: pm25AnnualAverage,
                    pollenPeakConcentration: pollenPeakConcentration,
                    pollenTypes: pollenTypes,
                    formaldehydeLevel: formaldehydeLevel,
                    dustMiteExposure: dustMiteExposure,
                    fabricFurnitureUse: fabricFurnitureUse
                )
            }
        }
        sqlite3_finalize(stmt)
        return result
    }
}
