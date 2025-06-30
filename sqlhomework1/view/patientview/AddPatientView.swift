//
//  AddPatientView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import SwiftUI

struct AddPatientView: View {
    // 基本字段
    @State private var visitDate = Date()
    @State private var name = ""
    @State private var gender = "男"
    @State private var birthdate = Date()
    @State private var age = ""
    @State private var address = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var birthWeight = ""
    @State private var lifestyle = ""
    @State private var phone = ""
    @State private var status = "在诊中"

    @State private var showAlert = false
    @State private var alertMessage = ""

    let genderOptions = ["男", "女", "其他"]
    let statusOptions = ["在诊中", "观察中", "痊愈", "复发"]

    let onSave: () -> Void
    let patientTable = PatientTable(db: DatabaseManager.shared.db)

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("姓名", text: $name)
                    DatePicker("就诊日期", selection: $visitDate, displayedComponents: .date)
                    Picker("性别", selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    BirthdayView(birthdate: $birthdate, age: $age)

                    TextField("地址", text: $address)

                    TextField("身高 (cm)", text: $height)
                        .keyboardType(.decimalPad)

                    TextField("体重 (kg)", text: $weight)
                        .keyboardType(.decimalPad)

                    TextField("出生体重 (kg)", text: $birthWeight)
                        .keyboardType(.decimalPad)

                    TextField("电话", text: $phone)
                        .keyboardType(.numberPad)
                        .onChange(of: phone) { oldValue, newValue in
                            phone = String(newValue.filter { "0123456789".contains($0) }.prefix(11))
                        }

                    Picker("状态", selection: $status) {
                        ForEach(statusOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                }
            }
            .navigationTitle("添加患者")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if validateFields() {
                            insertPatientToDB()
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
                Button("确定", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    func validateFields() -> Bool {
        if name.isEmpty {
            alertMessage = "请填写姓名"
            showAlert = true
            return false
        }
        if phone.isEmpty {
            alertMessage = "请填写电话"
            showAlert = true
            return false
        }
        if phone.count < 7 {
            alertMessage = "电话号码格式不正确"
            showAlert = true
            return false
        }
        if let ageInt = Int(age), ageInt < 0 || ageInt > 150 {
            alertMessage = "年龄填写不正确"
            showAlert = true
            return false
        }
        // 身高、体重、出生体重可选填，若填写要合法数字
        if !height.isEmpty, Double(height) == nil {
            alertMessage = "身高格式不正确"
            showAlert = true
            return false
        }
        if !weight.isEmpty, Double(weight) == nil {
            alertMessage = "体重格式不正确"
            showAlert = true
            return false
        }
        if !birthWeight.isEmpty, Double(birthWeight) == nil {
            alertMessage = "出生体重格式不正确"
            showAlert = true
            return false
        }
        return true
    }

    func insertPatientToDB() {
        // 格式化日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthdateString = dateFormatter.string(from: birthdate)
        let visitDateString = dateFormatter.string(from: visitDate)

        // 转换数字类型
        let ageInt = Int(age) ?? 0
        let heightDouble = Double(height) ?? 0.0
        let weightDouble = Double(weight) ?? 0.0
        let birthWeightDouble = Double(birthWeight) ?? 0.0

        patientTable.insertPatient(
            visitDate: visitDateString,
            name: name,
            gender: gender,
            birthDate: birthdateString,
            age: ageInt,
            address: address,
            height: heightDouble,
            weight: weightDouble,
            birthWeight: birthWeightDouble,
            lifestyle: lifestyle,
            phone: phone,
            status: status
        )
    }
}

struct BirthdayView: View {
    @Binding var birthdate: Date
    @Binding var age: String
    
    var body: some View {
        DatePicker("生日", selection: $birthdate, displayedComponents: .date)
            .onChange(of: birthdate) { oldValue, newValue in
                age = calculateAge(from: newValue)
            }
        
        HStack {
            Text("年龄")
            Spacer()
            Text(age + " 岁")
                .foregroundColor(.secondary)
        }
    }

    func calculateAge(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: date, to: now)
        return String(components.year ?? 0)
    }
}
