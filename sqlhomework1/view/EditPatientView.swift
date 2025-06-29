//
//  EditPatientView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import SwiftUI

struct EditPatientView: View {
    @Environment(\.dismiss) var dismiss

    @State var name: String
    @State var gender: String
    @State var birthdate: String
    @State var phone: String
    @State var status: String

    @State private var birthdateDate: Date

    let patientId: Int32
    let onSave: () -> Void
    let patientTable = PatientTable(db: DatabaseManager.shared.db)

    init(name: String, gender: String, birthdate: String, phone: String, status: String, patientId: Int32, onSave: @escaping () -> Void) {
        self._name = State(initialValue: name)
        self._gender = State(initialValue: gender)
        self._birthdate = State(initialValue: birthdate)
        self._phone = State(initialValue: phone)
        self._status = State(initialValue: status)
        self.patientId = patientId
        self.onSave = onSave
        
        // 将传入的 birthdate 字符串转换为 Date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: birthdate) {
            _birthdateDate = State(initialValue: date)
        } else {
            _birthdateDate = State(initialValue: Date())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("姓名", text: $name)
                Picker("性别", selection: $gender) {
                    Text("男").tag("男")
                    Text("女").tag("女")
                    Text("其他").tag("其他")
                }
                .pickerStyle(SegmentedPickerStyle())

                DatePicker("生日", selection: $birthdateDate, displayedComponents: .date)

                TextField("电话", text: $phone)
                    .keyboardType(.numberPad)

                Picker("就诊状态", selection: $status) {
                    Text("在诊中").tag("在诊中")
                    Text("观察中").tag("观察中")
                    Text("痊愈").tag("痊愈")
                    Text("复发").tag("复发")
                }
            }
            .navigationTitle("编辑患者信息")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        birthdate = formatter.string(from: birthdateDate)

                        patientTable.updatePatientInfo(
                            id: patientId,
                            name: name,
                            gender: gender,
                            birthdate: birthdate,
                            phone: phone,
                            status: status
                        )

                        onSave()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}
