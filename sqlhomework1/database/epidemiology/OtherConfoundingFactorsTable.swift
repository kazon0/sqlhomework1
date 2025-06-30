//
//  OtherConfoundingFactors.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//

import Foundation
import SQLite3


class OtherConfoundingFactorsTable {
    let db: OpaquePointer?
    
    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }
    
    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS OtherConfoundingFactors (
            PatientId INTEGER PRIMARY KEY,
            DietHighProcessed INTEGER,
            DietTraditional INTEGER,
            VitaminD_Daily400u INTEGER,
            VitaminD_DurationYears INTEGER,
            Omega3_IntakeMgPerDay INTEGER,
            StressLevel_PSS10 INTEGER,
            AnxietyDepression_PHQ9_GAD7 INTEGER,
            Vaccine_Planned INTEGER,
            Antibiotic_UseFrequency INTEGER,
            Breastfeeding INTEGER,
            BreastfeedingMonths INTEGER,
            Delivery_Natural INTEGER,
            Delivery_CSection INTEGER,
            PetExposureAge INTEGER,
            FarmExposure INTEGER,
            FarmExposureMonths INTEGER,
            AllergyAbsenceDaysPerYear INTEGER,
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "其他潜在混杂因素表创建成功")
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
        dietHighProcessed: Bool,
        dietTraditional: Bool,
        vitaminD_daily400u: Bool,
        vitaminD_durationYears: Int,
        omega3_intakeMgPerDay: Int,
        stressLevel_PSS10: Int,
        anxietyDepression_PHQ9_GAD7: Int,
        vaccine_planned: Bool,
        antibiotic_useFrequency: Int,
        breastfeeding: Bool,
        breastfeedingMonths: Int,
        delivery_natural: Bool,
        delivery_csection: Bool,
        petExposureAge: Int,
        farmExposure: Bool,
        farmExposureMonths: Int,
        allergyAbsenceDaysPerYear: Int
    ) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO OtherConfoundingFactors (
            PatientId,
            DietHighProcessed, DietTraditional,
            VitaminD_Daily400u, VitaminD_DurationYears,
            Omega3_IntakeMgPerDay,
            StressLevel_PSS10, AnxietyDepression_PHQ9_GAD7,
            Vaccine_Planned,
            Antibiotic_UseFrequency,
            Breastfeeding, BreastfeedingMonths,
            Delivery_Natural, Delivery_CSection,
            PetExposureAge,
            FarmExposure, FarmExposureMonths,
            AllergyAbsenceDaysPerYear
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            
            sqlite3_bind_int(stmt, 2, dietHighProcessed ? 1 : 0)
            sqlite3_bind_int(stmt, 3, dietTraditional ? 1 : 0)
            sqlite3_bind_int(stmt, 4, vitaminD_daily400u ? 1 : 0)
            sqlite3_bind_int(stmt, 5, Int32(vitaminD_durationYears))
            sqlite3_bind_int(stmt, 6, Int32(omega3_intakeMgPerDay))
            sqlite3_bind_int(stmt, 7, Int32(stressLevel_PSS10))
            sqlite3_bind_int(stmt, 8, Int32(anxietyDepression_PHQ9_GAD7))
            sqlite3_bind_int(stmt, 9, vaccine_planned ? 1 : 0)
            sqlite3_bind_int(stmt, 10, Int32(antibiotic_useFrequency))
            sqlite3_bind_int(stmt, 11, breastfeeding ? 1 : 0)
            sqlite3_bind_int(stmt, 12, Int32(breastfeedingMonths))
            sqlite3_bind_int(stmt, 13, delivery_natural ? 1 : 0)
            sqlite3_bind_int(stmt, 14, delivery_csection ? 1 : 0)
            sqlite3_bind_int(stmt, 15, Int32(petExposureAge))
            sqlite3_bind_int(stmt, 16, farmExposure ? 1 : 0)
            sqlite3_bind_int(stmt, 17, Int32(farmExposureMonths))
            sqlite3_bind_int(stmt, 18, Int32(allergyAbsenceDaysPerYear))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入/更新其他潜在混杂因素成功")
                return true
            }
        }
        sqlite3_finalize(stmt)
        print("插入/更新其他潜在混杂因素失败")
        return false
    }
    
    func query(patientId: Int32) -> OtherConfoundingFactors? {
        let sql = "SELECT * FROM OtherConfoundingFactors WHERE PatientId = ?;"
        var stmt: OpaquePointer?
        var result: OtherConfoundingFactors?
        
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                let dietHighProcessed = sqlite3_column_int(stmt, 1) == 1
                let dietTraditional = sqlite3_column_int(stmt, 2) == 1
                let vitaminD_daily400u = sqlite3_column_int(stmt, 3) == 1
                let vitaminD_durationYears = Int(sqlite3_column_int(stmt, 4))
                let omega3_intakeMgPerDay = Int(sqlite3_column_int(stmt, 5))
                let stressLevel_PSS10 = Int(sqlite3_column_int(stmt, 6))
                let anxietyDepression_PHQ9_GAD7 = Int(sqlite3_column_int(stmt, 7))
                let vaccine_planned = sqlite3_column_int(stmt, 8) == 1
                let antibiotic_useFrequency = Int(sqlite3_column_int(stmt, 9))
                let breastfeeding = sqlite3_column_int(stmt, 10) == 1
                let breastfeedingMonths = Int(sqlite3_column_int(stmt, 11))
                let delivery_natural = sqlite3_column_int(stmt, 12) == 1
                let delivery_csection = sqlite3_column_int(stmt, 13) == 1
                let petExposureAge = Int(sqlite3_column_int(stmt, 14))
                let farmExposure = sqlite3_column_int(stmt, 15) == 1
                let farmExposureMonths = Int(sqlite3_column_int(stmt, 16))
                let allergyAbsenceDaysPerYear = Int(sqlite3_column_int(stmt, 17))
                
                result = OtherConfoundingFactors(
                    patientId: patientId,
                    dietHighProcessed: dietHighProcessed,
                    dietTraditional: dietTraditional,
                    vitaminD_daily400u: vitaminD_daily400u,
                    vitaminD_durationYears: vitaminD_durationYears,
                    omega3_intakeMgPerDay: omega3_intakeMgPerDay,
                    stressLevel_PSS10: stressLevel_PSS10,
                    anxietyDepression_PHQ9_GAD7: anxietyDepression_PHQ9_GAD7,
                    vaccine_planned: vaccine_planned,
                    antibiotic_useFrequency: antibiotic_useFrequency,
                    breastfeeding: breastfeeding,
                    breastfeedingMonths: breastfeedingMonths,
                    delivery_natural: delivery_natural,
                    delivery_csection: delivery_csection,
                    petExposureAge: petExposureAge,
                    farmExposure: farmExposure,
                    farmExposureMonths: farmExposureMonths,
                    allergyAbsenceDaysPerYear: allergyAbsenceDaysPerYear
                )
            }
        }
        sqlite3_finalize(stmt)
        return result
    }
}
