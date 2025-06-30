//
//  ContactListView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct ContactListView: View {
    let patientId: Int32
    let table = ContactsTable(db: DatabaseManager.shared.db)

    @State private var contacts: [Contact] = []
    @State private var showingAddSheet = false
    @State private var editingContact: Contact? = nil

    var body: some View {
        VStack {
            if contacts.isEmpty {
                Spacer()
                Text("暂无联系人信息").foregroundColor(.gray).italic()
                Button("添加联系人") {
                    showingAddSheet = true
                }
                .padding()
                .background(Color.orange.gradient)
                .foregroundColor(.white)
                .cornerRadius(12)
                Spacer()
            } else {
                List {
                    ForEach(contacts) { contact in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(contact.name).font(.headline)
                            Text("关系: \(contact.relation)")
                            Text("电话: \(contact.phone)")
                            if !contact.address.isEmpty {
                                Text("地址: \(contact.address)")
                            }
                            if !contact.email.isEmpty {
                                Text("邮箱: \(contact.email)")
                            }
                            if !contact.remarks.isEmpty {
                                Text("备注: \(contact.remarks)")
                            }
                        }
                        .padding(.vertical, 6)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                table.deleteContact(by: contact.id)
                                refreshList()
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                editingContact = contact
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("联系人信息")
        .toolbar {
            Button {
                showingAddSheet = true
            } label: {
                Label("添加", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddContactView(patientId: patientId) {
                refreshList()
                showingAddSheet = false
            }
        }
        .sheet(item: $editingContact) { contact in
            EditContactView(contact: contact) {
                refreshList()
                editingContact = nil
            }
        }
        .onAppear {
            refreshList()
        }
    }

    func refreshList() {
        contacts = table.queryContacts(for: patientId)
    }
}
