//
//  AddPatientView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import SwiftUI

struct AddPatientView: View {
    @State private var name = ""
    @State private var gender = "男"
    @State private var birthdate = Date()
    @State private var phone = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    let genderOptions = ["男", "女", "其他"]
    let onSave: () -> Void
    let patientTable = PatientTable(db: DatabaseManager.shared.db)

    var body: some View {
        NavigationStack {
            Form {
                TextField("姓名", text: $name)

                Picker("性别", selection: $gender) {
                    ForEach(genderOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(.segmented)

                DatePicker("生日", selection: $birthdate, displayedComponents: .date)

                TextField("电话", text: $phone)
                    .keyboardType(.numberPad)
                    .onChange(of: phone) { oldValue, newValue in
                        // 只保留数字并限制最大长度
                        phone = String(newValue.prefix(11).filter { "0123456789".contains($0) })
                    }
            }
            .navigationTitle("添加患者")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if validateFields() {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let birthdateString = dateFormatter.string(from: birthdate)

                            patientTable.insertPatient(name: name, gender: gender, birthdate: birthdateString, phone: phone)
                            onSave()
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onSave()
                    }
                }
            }
            .alert("填写有误", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    func validateFields() -> Bool {
        if name.isEmpty || phone.isEmpty {
            alertMessage = "请填写姓名和电话。"
            showAlert = true
            return false
        }
        if phone.count < 7 {
            alertMessage = "电话号码格式不正确。"
            showAlert = true
            return false
        }
        return true
    }
}
