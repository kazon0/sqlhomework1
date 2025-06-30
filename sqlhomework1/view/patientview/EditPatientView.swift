//
//  EditPatientView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import SwiftUI

struct EditPatientView: View {
    @Environment(\.dismiss) var dismiss

    @State var visitDate: Date
    @State var name: String
    @State var gender: String
    @State var birthdate: Date
    @State var age: String
    @State var address: String
    @State var height: String
    @State var weight: String
    @State var birthWeight: String
    @State var lifestyle: String
    @State var phone: String
    @State var status: String

    let patientId: Int32
    let onSave: () -> Void
    let patientTable = PatientTable(db: DatabaseManager.shared.db)

    let genderOptions = ["男", "女", "其他"]
    let statusOptions = ["在诊中", "观察中", "痊愈", "复发"]

    init(
        patient: Patient,
        onSave: @escaping () -> Void
    ) {
        self.patientId = patient.id
        self.onSave = onSave

        // visitDate 和 birthdate 转成 Date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let vd = formatter.date(from: patient.visitDate) {
            _visitDate = State(initialValue: vd)
        } else {
            _visitDate = State(initialValue: Date())
        }

        _name = State(initialValue: patient.name)
        _gender = State(initialValue: patient.gender)
        if let bd = formatter.date(from: patient.birthDate) {
            _birthdate = State(initialValue: bd)
        } else {
            _birthdate = State(initialValue: Date())
        }
        _age = State(initialValue: String(patient.age))
        _address = State(initialValue: patient.address)
        _height = State(initialValue: String(format: "%.2f", patient.height))
        _weight = State(initialValue: String(format: "%.2f", patient.weight))
        _birthWeight = State(initialValue: String(format: "%.2f", patient.birthWeight))
        _lifestyle = State(initialValue: patient.lifestyle)
        _phone = State(initialValue: patient.phone)
        _status = State(initialValue: patient.status)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("姓名", text: $name)
                        .multilineTextAlignment(.leading)
                    DatePicker("就诊日期", selection: $visitDate, displayedComponents: .date)
                    Picker("性别", selection: $gender) {
                        ForEach(genderOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)

                    BirthdayView(birthdate: $birthdate, age: $age)

                    TextField("地址", text: $address)
                        .multilineTextAlignment(.leading)

                    TextField("身高 (cm)", text: $height)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)

                    TextField("体重 (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)

                    TextField("出生体重 (kg)", text: $birthWeight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)

                    TextField("电话", text: $phone)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.numberPad)
                        .onChange(of: phone) { oldValue, newValue in
                            phone = String(newValue.filter { "0123456789".contains($0) }.prefix(11))
                        }

                    Picker("状态", selection: $status) {
                        ForEach(statusOptions, id: \.self) { Text($0) }
                    }
                }
            }
            .navigationTitle("编辑患者信息")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
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

    func saveChanges() {
        // 验证部分字段
        guard !name.isEmpty else {
            // 可改为显示 alert
            print("姓名不能为空")
            return
        }
        guard !phone.isEmpty, phone.count >= 7 else {
            print("电话格式错误")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let visitDateString = formatter.string(from: visitDate)
        let birthdateString = formatter.string(from: birthdate)

        let ageInt = Int(age) ?? 0
        let heightDouble = Double(height) ?? 0.0
        let weightDouble = Double(weight) ?? 0.0
        let birthWeightDouble = Double(birthWeight) ?? 0.0

        patientTable.updatePatientInfo(
            id: patientId,
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

        onSave()
        dismiss()
    }
}
