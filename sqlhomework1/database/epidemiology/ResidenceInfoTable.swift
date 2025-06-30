//
//  ResidenceInfoTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//


import Foundation
import SQLite3

class ResidenceInfoTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS ResidenceInfo (
            PatientId INTEGER PRIMARY KEY,
            HouseType TEXT,
            BuildingMaterial TEXT,
            VentilationFrequency TEXT,
            ACUsageSeason TEXT,
            ACFrequency TEXT,
            ACTemperatureSetting TEXT,
            ACMode TEXT,
            ACFilterCleaningFrequency TEXT,
            HeatingUsageFrequency TEXT,
            RoomTemperatureRange TEXT,
            HasCarpet INTEGER,
            HasStuffedToys INTEGER,
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "居住信息表创建成功")
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
        houseType: String,
        buildingMaterial: String,
        ventilationFrequency: String,
        acUsageSeason: String,
        acFrequency: String,
        acTemperatureSetting: String,
        acMode: String,
        acFilterCleaningFrequency: String,
        heatingUsageFrequency: String,
        roomTemperatureRange: String,
        hasCarpet: Bool,
        hasStuffedToys: Bool
    ) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO ResidenceInfo (
            PatientId, HouseType, BuildingMaterial, VentilationFrequency, ACUsageSeason,
            ACFrequency, ACTemperatureSetting, ACMode, ACFilterCleaningFrequency,
            HeatingUsageFrequency, RoomTemperatureRange, HasCarpet, HasStuffedToys
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (houseType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (buildingMaterial as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (ventilationFrequency as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (acUsageSeason as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (acFrequency as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (acTemperatureSetting as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 8, (acMode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 9, (acFilterCleaningFrequency as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 10, (heatingUsageFrequency as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 11, (roomTemperatureRange as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 12, hasCarpet ? 1 : 0)
            sqlite3_bind_int(stmt, 13, hasStuffedToys ? 1 : 0)

            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入/更新居住信息成功")
                return true
            }
        }
        sqlite3_finalize(stmt)
        print("插入/更新居住信息失败")
        return false
    }

    func query(patientId: Int32) -> ResidenceInfo? {
        let sql = "SELECT * FROM ResidenceInfo WHERE PatientId = ?;"
        var stmt: OpaquePointer?
        var result: ResidenceInfo?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            if sqlite3_step(stmt) == SQLITE_ROW {
                let houseType = String(cString: sqlite3_column_text(stmt, 1))
                let buildingMaterial = String(cString: sqlite3_column_text(stmt, 2))
                let ventilationFrequency = String(cString: sqlite3_column_text(stmt, 3))
                let acUsageSeason = String(cString: sqlite3_column_text(stmt, 4))
                let acFrequency = String(cString: sqlite3_column_text(stmt, 5))
                let acTemperatureSetting = String(cString: sqlite3_column_text(stmt, 6))
                let acMode = String(cString: sqlite3_column_text(stmt, 7))
                let acFilterCleaningFrequency = String(cString: sqlite3_column_text(stmt, 8))
                let heatingUsageFrequency = String(cString: sqlite3_column_text(stmt, 9))
                let roomTemperatureRange = String(cString: sqlite3_column_text(stmt, 10))
                let hasCarpet = sqlite3_column_int(stmt, 11) == 1
                let hasStuffedToys = sqlite3_column_int(stmt, 12) == 1

                result = ResidenceInfo(
                    patientId: patientId,
                    houseType: houseType,
                    buildingMaterial: buildingMaterial,
                    ventilationFrequency: ventilationFrequency,
                    acUsageSeason: acUsageSeason,
                    acFrequency: acFrequency,
                    acTemperatureSetting: acTemperatureSetting,
                    acMode: acMode,
                    acFilterCleaningFrequency: acFilterCleaningFrequency,
                    heatingUsageFrequency: heatingUsageFrequency,
                    roomTemperatureRange: roomTemperatureRange,
                    hasCarpet: hasCarpet,
                    hasStuffedToys: hasStuffedToys
                )
            }
        }
        sqlite3_finalize(stmt)
        return result
    }
}

