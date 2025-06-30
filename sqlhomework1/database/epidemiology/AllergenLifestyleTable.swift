//
//  AllergenLifestyle.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//

import Foundation
import SQLite3

class AllergenLifestyleTable {
    let db: OpaquePointer?
    
    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }
    
    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS AllergenLifestyle (
            PatientId INTEGER PRIMARY KEY,
            PM25Concentration REAL,
            PollenTypes TEXT,
            FormaldehydeConcentration REAL,
            FormaldehydeTestDate TEXT,
            DustMiteConcentration REAL,
            OtherAllergens TEXT,
            
            ExerciseFrequencyPerWeek INTEGER,
            ExerciseDurationMinutes INTEGER,
            ExerciseIntensity TEXT,
            Swimming INTEGER,
            
            SleepHoursPerDay REAL,
            HasInsomnia INTEGER,
            CircadianRhythmDisorder INTEGER,
            
            SmokingStatus TEXT,
            CleaningFrequency TEXT,
            
            HasCat INTEGER,
            HasDog INTEGER,
            HasBird INTEGER,
            OtherPets TEXT,
            PetCount INTEGER,
            
            SmokerCohabitant INTEGER,
            
            CookingFuelType TEXT,
            AirPurifierUsed INTEGER,
            VacuumCleanerUsed INTEGER,
            
            AllergenAvoidanceEffectiveness TEXT,
            
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "过敏原及生活状态表创建成功")
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
        pm25Concentration: Double,
        pollenTypes: String,
        formaldehydeConcentration: Double,
        formaldehydeTestDate: String,
        dustMiteConcentration: Double,
        otherAllergens: String,
        exerciseFrequencyPerWeek: Int,
        exerciseDurationMinutes: Int,
        exerciseIntensity: String,
        swimming: Bool,
        sleepHoursPerDay: Double,
        hasInsomnia: Bool,
        circadianRhythmDisorder: Bool,
        smokingStatus: String,
        cleaningFrequency: String,
        hasCat: Bool,
        hasDog: Bool,
        hasBird: Bool,
        otherPets: String,
        petCount: Int,
        smokerCohabitant: Bool,
        cookingFuelType: String,
        airPurifierUsed: Bool,
        vacuumCleanerUsed: Bool,
        allergenAvoidanceEffectiveness: String
    ) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO AllergenLifestyle (
            PatientId, PM25Concentration, PollenTypes, FormaldehydeConcentration, FormaldehydeTestDate,
            DustMiteConcentration, OtherAllergens, ExerciseFrequencyPerWeek, ExerciseDurationMinutes,
            ExerciseIntensity, Swimming, SleepHoursPerDay, HasInsomnia, CircadianRhythmDisorder,
            SmokingStatus, CleaningFrequency, HasCat, HasDog, HasBird, OtherPets, PetCount,
            SmokerCohabitant, CookingFuelType, AirPurifierUsed, VacuumCleanerUsed,
            AllergenAvoidanceEffectiveness
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_double(stmt, 2, pm25Concentration)
            sqlite3_bind_text(stmt, 3, (pollenTypes as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 4, formaldehydeConcentration)
            sqlite3_bind_text(stmt, 5, (formaldehydeTestDate as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 6, dustMiteConcentration)
            sqlite3_bind_text(stmt, 7, (otherAllergens as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(stmt, 8, Int32(exerciseFrequencyPerWeek))
            sqlite3_bind_int(stmt, 9, Int32(exerciseDurationMinutes))
            sqlite3_bind_text(stmt, 10, (exerciseIntensity as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 11, swimming ? 1 : 0)
            
            sqlite3_bind_double(stmt, 12, sleepHoursPerDay)
            sqlite3_bind_int(stmt, 13, hasInsomnia ? 1 : 0)
            sqlite3_bind_int(stmt, 14, circadianRhythmDisorder ? 1 : 0)
            
            sqlite3_bind_text(stmt, 15, (smokingStatus as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 16, (cleaningFrequency as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(stmt, 17, hasCat ? 1 : 0)
            sqlite3_bind_int(stmt, 18, hasDog ? 1 : 0)
            sqlite3_bind_int(stmt, 19, hasBird ? 1 : 0)
            sqlite3_bind_text(stmt, 20, (otherPets as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 21, Int32(petCount))
            
            sqlite3_bind_int(stmt, 22, smokerCohabitant ? 1 : 0)
            
            sqlite3_bind_text(stmt, 23, (cookingFuelType as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 24, airPurifierUsed ? 1 : 0)
            sqlite3_bind_int(stmt, 25, vacuumCleanerUsed ? 1 : 0)
            
            sqlite3_bind_text(stmt, 26, (allergenAvoidanceEffectiveness as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入/更新过敏原及生活状态成功")
                return true
            }
        }
        sqlite3_finalize(stmt)
        print("插入/更新过敏原及生活状态失败")
        return false
    }
    
    func query(patientId: Int32) -> AllergenLifestyle? {
        let sql = "SELECT * FROM AllergenLifestyle WHERE PatientId = ?;"
        var stmt: OpaquePointer?
        var result: AllergenLifestyle?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            if sqlite3_step(stmt) == SQLITE_ROW {
                let pm25Concentration = sqlite3_column_double(stmt, 1)
                let pollenTypes = String(cString: sqlite3_column_text(stmt, 2))
                let formaldehydeConcentration = sqlite3_column_double(stmt, 3)
                let formaldehydeTestDate = String(cString: sqlite3_column_text(stmt, 4))
                let dustMiteConcentration = sqlite3_column_double(stmt, 5)
                let otherAllergens = String(cString: sqlite3_column_text(stmt, 6))
                
                let exerciseFrequencyPerWeek = Int(sqlite3_column_int(stmt, 7))
                let exerciseDurationMinutes = Int(sqlite3_column_int(stmt, 8))
                let exerciseIntensity = String(cString: sqlite3_column_text(stmt, 9))
                let swimming = sqlite3_column_int(stmt, 10) == 1
                
                let sleepHoursPerDay = sqlite3_column_double(stmt, 11)
                let hasInsomnia = sqlite3_column_int(stmt, 12) == 1
                let circadianRhythmDisorder = sqlite3_column_int(stmt, 13) == 1
                
                let smokingStatus = String(cString: sqlite3_column_text(stmt, 14))
                let cleaningFrequency = String(cString: sqlite3_column_text(stmt, 15))
                
                let hasCat = sqlite3_column_int(stmt, 16) == 1
                let hasDog = sqlite3_column_int(stmt, 17) == 1
                let hasBird = sqlite3_column_int(stmt, 18) == 1
                let otherPets = String(cString: sqlite3_column_text(stmt, 19))
                let petCount = Int(sqlite3_column_int(stmt, 20))
                
                let smokerCohabitant = sqlite3_column_int(stmt, 21) == 1
                
                let cookingFuelType = String(cString: sqlite3_column_text(stmt, 22))
                let airPurifierUsed = sqlite3_column_int(stmt, 23) == 1
                let vacuumCleanerUsed = sqlite3_column_int(stmt, 24) == 1
                
                let allergenAvoidanceEffectiveness = String(cString: sqlite3_column_text(stmt, 25))
                
                result = AllergenLifestyle(
                    patientId: patientId,
                    pm25Concentration: pm25Concentration,
                    pollenTypes: pollenTypes,
                    formaldehydeConcentration: formaldehydeConcentration,
                    formaldehydeTestDate: formaldehydeTestDate,
                    dustMiteConcentration: dustMiteConcentration,
                    otherAllergens: otherAllergens,
                    exerciseFrequencyPerWeek: exerciseFrequencyPerWeek,
                    exerciseDurationMinutes: exerciseDurationMinutes,
                    exerciseIntensity: exerciseIntensity,
                    swimming: swimming,
                    sleepHoursPerDay: sleepHoursPerDay,
                    hasInsomnia: hasInsomnia,
                    circadianRhythmDisorder: circadianRhythmDisorder,
                    smokingStatus: smokingStatus,
                    cleaningFrequency: cleaningFrequency,
                    hasCat: hasCat,
                    hasDog: hasDog,
                    hasBird: hasBird,
                    otherPets: otherPets,
                    petCount: petCount,
                    smokerCohabitant: smokerCohabitant,
                    cookingFuelType: cookingFuelType,
                    airPurifierUsed: airPurifierUsed,
                    vacuumCleanerUsed: vacuumCleanerUsed,
                    allergenAvoidanceEffectiveness: allergenAvoidanceEffectiveness
                )
            }
        }
        sqlite3_finalize(stmt)
        return result
    }
}
