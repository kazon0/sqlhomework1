//
//  UrbanRuralEnvironment.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//

import Foundation
import SQLite3

class UrbanRuralEnvironmentTable {
    let db: OpaquePointer?
    
    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }
    
    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS UrbanRuralEnvironment (
            PatientId INTEGER PRIMARY KEY,
            
            CityPM25AnnualAverage REAL,
            CityPM25SeasonalVariation TEXT,
            CityPollenMainTypes TEXT,
            CityPollenMonthlyDistribution TEXT,
            CityPollenPeakConcentration REAL,
            CityOtherPollutants TEXT,
            CityMonitoringSiteType TEXT,
            
            RuralPM25BurningPeriod REAL,
            RuralPM25AnnualAverage REAL,
            RuralCropPollenTypes TEXT,
            BiomassFuelIndoorPollution INTEGER,
            DrinkingWaterSource TEXT,
            
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "城乡环境监测表创建成功")
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
        cityPM25AnnualAverage: Double,
        cityPM25SeasonalVariation: String,
        cityPollenMainTypes: String,
        cityPollenMonthlyDistribution: String,
        cityPollenPeakConcentration: Double,
        cityOtherPollutants: String,
        cityMonitoringSiteType: String,
        ruralPM25BurningPeriod: Double,
        ruralPM25AnnualAverage: Double,
        ruralCropPollenTypes: String,
        biomassFuelIndoorPollution: Bool,
        drinkingWaterSource: String
    ) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO UrbanRuralEnvironment (
            PatientId, CityPM25AnnualAverage, CityPM25SeasonalVariation,
            CityPollenMainTypes, CityPollenMonthlyDistribution, CityPollenPeakConcentration,
            CityOtherPollutants, CityMonitoringSiteType, RuralPM25BurningPeriod,
            RuralPM25AnnualAverage, RuralCropPollenTypes, BiomassFuelIndoorPollution,
            DrinkingWaterSource
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_double(stmt, 2, cityPM25AnnualAverage)
            sqlite3_bind_text(stmt, 3, (cityPM25SeasonalVariation as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (cityPollenMainTypes as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (cityPollenMonthlyDistribution as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 6, cityPollenPeakConcentration)
            sqlite3_bind_text(stmt, 7, (cityOtherPollutants as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 8, (cityMonitoringSiteType as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 9, ruralPM25BurningPeriod)
            sqlite3_bind_double(stmt, 10, ruralPM25AnnualAverage)
            sqlite3_bind_text(stmt, 11, (ruralCropPollenTypes as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 12, biomassFuelIndoorPollution ? 1 : 0)
            sqlite3_bind_text(stmt, 13, (drinkingWaterSource as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入/更新城乡环境监测成功")
                return true
            }
        }
        sqlite3_finalize(stmt)
        print("插入/更新城乡环境监测失败")
        return false
    }
    
    func query(patientId: Int32) -> UrbanRuralEnvironment? {
        let sql = "SELECT * FROM UrbanRuralEnvironment WHERE PatientId = ?;"
        var stmt: OpaquePointer?
        var result: UrbanRuralEnvironment?
        
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            if sqlite3_step(stmt) == SQLITE_ROW {
                let cityPM25AnnualAverage = sqlite3_column_double(stmt, 1)
                let cityPM25SeasonalVariation = String(cString: sqlite3_column_text(stmt, 2))
                let cityPollenMainTypes = String(cString: sqlite3_column_text(stmt, 3))
                let cityPollenMonthlyDistribution = String(cString: sqlite3_column_text(stmt, 4))
                let cityPollenPeakConcentration = sqlite3_column_double(stmt, 5)
                let cityOtherPollutants = String(cString: sqlite3_column_text(stmt, 6))
                let cityMonitoringSiteType = String(cString: sqlite3_column_text(stmt, 7))
                
                let ruralPM25BurningPeriod = sqlite3_column_double(stmt, 8)
                let ruralPM25AnnualAverage = sqlite3_column_double(stmt, 9)
                let ruralCropPollenTypes = String(cString: sqlite3_column_text(stmt, 10))
                let biomassFuelIndoorPollution = sqlite3_column_int(stmt, 11) == 1
                let drinkingWaterSource = String(cString: sqlite3_column_text(stmt, 12))
                
                result = UrbanRuralEnvironment(
                    patientId: patientId,
                    cityPM25AnnualAverage: cityPM25AnnualAverage,
                    cityPM25SeasonalVariation: cityPM25SeasonalVariation,
                    cityPollenMainTypes: cityPollenMainTypes,
                    cityPollenMonthlyDistribution: cityPollenMonthlyDistribution,
                    cityPollenPeakConcentration: cityPollenPeakConcentration,
                    cityOtherPollutants: cityOtherPollutants,
                    cityMonitoringSiteType: cityMonitoringSiteType,
                    ruralPM25BurningPeriod: ruralPM25BurningPeriod,
                    ruralPM25AnnualAverage: ruralPM25AnnualAverage,
                    ruralCropPollenTypes: ruralCropPollenTypes,
                    biomassFuelIndoorPollution: biomassFuelIndoorPollution,
                    drinkingWaterSource: drinkingWaterSource
                )
            }
        }
        sqlite3_finalize(stmt)
        return result
    }
}
