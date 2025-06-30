//
//  EditContactView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct EditContactView: View {
    @Environment(\.dismiss) var dismiss

    @State var contact: Contact
    let onSave: () -> Void
    let table = ContactsTable(db: DatabaseManager.shared.db)

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("编辑联系人")) {
                    TextField("姓名", text: $contact.name)
                    TextField("关系", text: $contact.relation)
                    TextField("电话", text: $contact.phone)
                        .keyboardType(.phonePad)
                    TextField("地址", text: $contact.address)
                    TextField("邮箱", text: $contact.email)
                        .keyboardType(.emailAddress)
                    TextField("备注", text: $contact.remarks)
                }
            }
            .navigationTitle("编辑联系人")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(contact.name.isEmpty || contact.phone.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    func saveChanges() {
        table.updateContact(
            id: contact.id,
            name: contact.name,
            relation: contact.relation,
            phone: contact.phone,
            address: contact.address,
            email: contact.email,
            remarks: contact.remarks
        )
        onSave()
        dismiss()
    }
}
