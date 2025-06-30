//
//  AddContactView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) var dismiss

    let patientId: Int32
    let onSave: () -> Void
    let table = ContactsTable(db: DatabaseManager.shared.db)

    @State private var name = ""
    @State private var relation = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var email = ""
    @State private var remarks = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("联系人信息")) {
                    TextField("姓名", text: $name)
                    TextField("关系", text: $relation)
                    TextField("电话", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("地址", text: $address)
                    TextField("邮箱", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("备注", text: $remarks)
                }
            }
            .navigationTitle("添加联系人")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveContact()
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    func saveContact() {
        table.insertContact(
            patientId: patientId,
            name: name,
            relation: relation,
            phone: phone,
            address: address,
            email: email,
            remarks: remarks
        )
        onSave()
        dismiss()
    }
}
