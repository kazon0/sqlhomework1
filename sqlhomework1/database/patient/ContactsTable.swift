//
//  ContactsTable.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import Foundation
import SQLite3

class ContactsTable {
    let db: OpaquePointer?

    init(db: OpaquePointer?) {
        self.db = db
        createTable()
    }

    func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS Contacts (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientId INTEGER,
            Name TEXT,
            Relation TEXT,
            Phone TEXT,
            Address TEXT,
            Email TEXT,
            Remarks TEXT,
            FOREIGN KEY(PatientId) REFERENCES Patients(Id)
        );
        """
        executeSQL(sql, successMessage: "联系人信息表创建成功")
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

    func insertContact(patientId: Int32, name: String, relation: String, phone: String, address: String, email: String, remarks: String) {
        let sql = "INSERT INTO Contacts (PatientId, Name, Relation, Phone, Address, Email, Remarks) VALUES (?, ?, ?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)
            sqlite3_bind_text(stmt, 2, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (relation as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (remarks as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("插入联系人成功")
            } else {
                print("插入联系人失败")
            }
        } else {
            print("插入语句准备失败")
        }
        sqlite3_finalize(stmt)
    }

    func queryContacts(for patientId: Int32) -> [Contact] {
        var result: [Contact] = []
        let query = "SELECT * FROM Contacts WHERE PatientId = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, patientId)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let patientId = sqlite3_column_int(stmt, 1)
                let name = String(cString: sqlite3_column_text(stmt, 2))
                let relation = String(cString: sqlite3_column_text(stmt, 3))
                let phone = String(cString: sqlite3_column_text(stmt, 4))
                let address = String(cString: sqlite3_column_text(stmt, 5))
                let email = String(cString: sqlite3_column_text(stmt, 6))
                let remarks = String(cString: sqlite3_column_text(stmt, 7))

                result.append(Contact(id: id, patientId: patientId, name: name, relation: relation, phone: phone, address: address, email: email, remarks: remarks))
            }
        }

        sqlite3_finalize(stmt)
        return result
    }

    func deleteContact(by id: Int32) {
        let sql = "DELETE FROM Contacts WHERE Id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("删除联系人成功")
            }
        }
        sqlite3_finalize(stmt)
    }

    func updateContact(id: Int32, name: String, relation: String, phone: String, address: String, email: String, remarks: String) {
        let sql = """
        UPDATE Contacts SET
            Name = ?,
            Relation = ?,
            Phone = ?,
            Address = ?,
            Email = ?,
            Remarks = ?
        WHERE Id = ?;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (relation as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (remarks as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, id)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("更新联系人成功")
            } else {
                print("更新联系人失败")
            }
        } else {
            print("更新语句准备失败")
        }
        sqlite3_finalize(stmt)
    }
}
