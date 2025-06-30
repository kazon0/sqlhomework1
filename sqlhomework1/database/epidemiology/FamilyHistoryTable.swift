//
//  FamilyHistory.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//

import Foundation
import SQLite3

class FamilyHistoryTable {
    let db: OpaquePointer?
    
    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }
    
    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS FamilyHistory (
            PatientId INTEGER PRIMARY KEY,
            
            AsthmaFirstDegree INTEGER,
            EczemaFirstDegree INTEGER,
            RhinitisFirstDegree INTEGER,
            FoodAllergyFirstDegree INTEGER,
            RelationFirstDegree TEXT,
            
            AsthmaSecondDegree INTEGER,
            EczemaSecondDegree INTEGER,
            RhinitisSecondDegree INTEGER,
            FoodAllergySecondDegree INTEGER,
            RelationSecondDegree TEXT,
            
            SharedExposureSmoking INTEGER,
            
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "家族史表创建成功")
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
        asthmaFirstDegree: Bool,
        eczemaFirstDegree: Bool,
        rhinitisFirstDegree: Bool,
        foodAllergyFirstDegree: Bool,
        relationFirstDegree: String,
        asthmaSecondDegree: Bool,
        eczemaSecondDegree: Bool,
        rhinitisSecondDegree: Bool,
        foodAllergySecondDegree: Bool,
        relationSecondDegree: String,
        sharedExposureSmoking: Bool
    ) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO FamilyHistory (
            PatientId,
            AsthmaFirstDegree, EczemaFirstDegree, RhinitisFirstDegree, FoodAllergyFirstDegree, RelationFirstDegree,
            AsthmaSecondDegree, EczemaSecondDegree, RhinitisSecondDegree, FoodAllergySecondDegree, RelationSecondDegree,
            SharedExposureSmoking
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            
            sqlite3_bind_int(stmt, 2, asthmaFirstDegree ? 1 : 0)
            sqlite3_bind_int(stmt, 3, eczemaFirstDegree ? 1 : 0)
            sqlite3_bind_int(stmt, 4, rhinitisFirstDegree ? 1 : 0)
            sqlite3_bind_int(stmt, 5, foodAllergyFirstDegree ? 1 : 0)
            sqlite3_bind_text(stmt, 6, (relationFirstDegree as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(stmt, 7, asthmaSecondDegree ? 1 : 0)
            sqlite3_bind_int(stmt, 8, eczemaSecondDegree ? 1 : 0)
            sqlite3_bind_int(stmt, 9, rhinitisSecondDegree ? 1 : 0)
            sqlite3_bind_int(stmt, 10, foodAllergySecondDegree ? 1 : 0)
            sqlite3_bind_text(stmt, 11, (relationSecondDegree as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(stmt, 12, sharedExposureSmoking ? 1 : 0)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入/更新家族史成功")
                return true
            }
        }
        sqlite3_finalize(stmt)
        print("插入/更新家族史失败")
        return false
    }
    
    func query(patientId: Int32) -> FamilyHistory? {
        let sql = "SELECT * FROM FamilyHistory WHERE PatientId = ?;"
        var stmt: OpaquePointer?
        var result: FamilyHistory?
        
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                let asthmaFirstDegree = sqlite3_column_int(stmt, 1) == 1
                let eczemaFirstDegree = sqlite3_column_int(stmt, 2) == 1
                let rhinitisFirstDegree = sqlite3_column_int(stmt, 3) == 1
                let foodAllergyFirstDegree = sqlite3_column_int(stmt, 4) == 1
                let relationFirstDegree = String(cString: sqlite3_column_text(stmt, 5))
                
                let asthmaSecondDegree = sqlite3_column_int(stmt, 6) == 1
                let eczemaSecondDegree = sqlite3_column_int(stmt, 7) == 1
                let rhinitisSecondDegree = sqlite3_column_int(stmt, 8) == 1
                let foodAllergySecondDegree = sqlite3_column_int(stmt, 9) == 1
                let relationSecondDegree = String(cString: sqlite3_column_text(stmt, 10))
                
                let sharedExposureSmoking = sqlite3_column_int(stmt, 11) == 1
                
                result = FamilyHistory(
                    patientId: patientId,
                    asthmaFirstDegree: asthmaFirstDegree,
                    eczemaFirstDegree: eczemaFirstDegree,
                    rhinitisFirstDegree: rhinitisFirstDegree,
                    foodAllergyFirstDegree: foodAllergyFirstDegree,
                    relationFirstDegree: relationFirstDegree,
                    asthmaSecondDegree: asthmaSecondDegree,
                    eczemaSecondDegree: eczemaSecondDegree,
                    rhinitisSecondDegree: rhinitisSecondDegree,
                    foodAllergySecondDegree: foodAllergySecondDegree,
                    relationSecondDegree: relationSecondDegree,
                    sharedExposureSmoking: sharedExposureSmoking
                )
            }
        }
        sqlite3_finalize(stmt)
        return result
    }
}
