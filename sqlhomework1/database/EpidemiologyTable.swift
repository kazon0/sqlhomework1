//
//  EpidemiologyTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import Foundation
import SQLite3

class EpidemiologyTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
        migrateTable()
    }

    // 只创建最初版本字段，后续字段用 ALTER 添加
    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS Epidemiology(
            PatientId INTEGER PRIMARY KEY,
            Pets INTEGER,
            DustExposure INTEGER,
            FamilyHistory INTEGER,
            Smoking INTEGER,
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "流行病学调查表创建成功")
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

    func migrateTable() {
        func columnExists(_ columnName: String) -> Bool {
            let pragmaSQL = "PRAGMA table_info(Epidemiology);"
            var stmt: OpaquePointer?
            var exists = false
            if sqlite3_prepare_v2(db, pragmaSQL, -1, &stmt, nil) == SQLITE_OK {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    if let cName = sqlite3_column_text(stmt, 1) {
                        let name = String(cString: cName)
                        if name == columnName {
                            exists = true
                            break
                        }
                    }
                }
            }
            sqlite3_finalize(stmt)
            return exists
        }

        let newColumns: [(name: String, sql: String)] = [
            ("ResidenceType", "TEXT DEFAULT ''"),
            ("MoldExposure", "INTEGER DEFAULT 0"),
            ("SecondHandSmoke", "INTEGER DEFAULT 0"),
            ("Ventilation", "INTEGER DEFAULT 0"),
            ("Humidity", "TEXT DEFAULT ''")
        ]

        for col in newColumns {
            if !columnExists(col.name) {
                let alterSQL = "ALTER TABLE Epidemiology ADD COLUMN \(col.name) \(col.sql);"
                executeSQL(alterSQL, successMessage: "添加字段 \(col.name) 成功")
            }
        }
    }

    // 新增字段加参数，插入时绑定
    func insertEpidemiology(
        patientId: Int32,
        pets: Bool,
        dustExposure: Bool,
        familyHistory: Bool,
        smoking: Bool,
        residenceType: String = "",
        moldExposure: Bool = false,
        secondHandSmoke: Bool = false,
        ventilation: Bool = false,
        humidity: String = ""
    ) -> (success: Bool, errorMessage: String?) {
        let sql = """
        INSERT OR REPLACE INTO Epidemiology (
            PatientId, Pets, DustExposure, FamilyHistory, Smoking,
            ResidenceType, MoldExposure, SecondHandSmoke, Ventilation, Humidity
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_int(stmt, 2, pets ? 1 : 0)
            sqlite3_bind_int(stmt, 3, dustExposure ? 1 : 0)
            sqlite3_bind_int(stmt, 4, familyHistory ? 1 : 0)
            sqlite3_bind_int(stmt, 5, smoking ? 1 : 0)
            sqlite3_bind_text(stmt, 6, (residenceType as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, moldExposure ? 1 : 0)
            sqlite3_bind_int(stmt, 8, secondHandSmoke ? 1 : 0)
            sqlite3_bind_int(stmt, 9, ventilation ? 1 : 0)
            sqlite3_bind_text(stmt, 10, (humidity as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                print("插入/更新流行病学成功")
                return (true, nil)
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(db))
                print("插入失败: \(errorMsg)")
                sqlite3_finalize(stmt)
                return (false, errorMsg)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("插入语句准备失败: \(errorMsg)")
            return (false, errorMsg)
        }
    }

    // 查询时注意列索引和数据类型匹配
    func queryEpidemiology(for patientId: Int32) -> Epidemiology? {
        let sql = "SELECT * FROM Epidemiology WHERE PatientId = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            if sqlite3_step(stmt) == SQLITE_ROW {
                // 注意索引要对应表结构顺序：PatientId(0), Pets(1), DustExposure(2), FamilyHistory(3), Smoking(4), ...
                let pets = sqlite3_column_int(stmt, 1) == 1
                let dustExposure = sqlite3_column_int(stmt, 2) == 1
                let familyHistory = sqlite3_column_int(stmt, 3) == 1
                let smoking = sqlite3_column_int(stmt, 4) == 1

                let residenceType = sqlite3_column_text(stmt, 5).flatMap { String(cString: $0) } ?? ""
                let moldExposure = sqlite3_column_int(stmt, 6) == 1
                let secondHandSmoke = sqlite3_column_int(stmt, 7) == 1
                let ventilation = sqlite3_column_int(stmt, 8) == 1
                let humidity = sqlite3_column_text(stmt, 9).flatMap { String(cString: $0) } ?? ""

                sqlite3_finalize(stmt)

                return Epidemiology(
                    patientId: patientId,
                    pets: pets,
                    dustExposure: dustExposure,
                    familyHistory: familyHistory,
                    smoking: smoking,
                    residenceType: residenceType,
                    moldExposure: moldExposure,
                    secondHandSmoke: secondHandSmoke,
                    ventilation: ventilation,
                    humidity: humidity
                )
            }
        }

        sqlite3_finalize(stmt)
        return nil
    }
}
