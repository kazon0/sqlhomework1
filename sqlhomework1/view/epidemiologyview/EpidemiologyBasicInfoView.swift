//
//  EpidemiologyBasicInfoView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//


import SwiftUI

struct EpidemiologyBasicInfoView: View {
    let patientId: Int32
    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var investigationDate = Date()
    @State private var patientName = ""
    @State private var gender = "男"
    @State private var age = ""
    @State private var residenceType = ""
    @State private var residenceYears = ""
    @State private var address = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var hasAllergyHistory = false
    @State private var allergyDiseases = Set<String>()
    @State private var currentDiagnoses = Set<String>()
    @State private var investigatorName = ""
    @State private var investigatorTitle = ""
    
    let table = EpidemiologyMainTable(db: DatabaseManager.shared.db)

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func load() {
        if let data = table.query(patientId: patientId) {
            if let parsedDate = dateFormatter.date(from: data.investigationDate) {
                investigationDate = parsedDate
            } else {
                print("无法解析日期字符串：\(data.investigationDate)")
            }
            patientName = data.patientName
            gender = data.gender
            age = "\(data.age)"
            residenceType = data.residenceType
            residenceYears = "\(data.residenceYears)"
            address = data.address
            height = "\(data.height)"
            weight = "\(data.weight)"
            hasAllergyHistory = data.hasAllergyHistory
            allergyDiseases = Set(data.allergyDiseases.split(separator: ",").map { String($0) })
            currentDiagnoses = Set(data.currentDiagnoses.split(separator: ",").map { String($0) })
            investigatorName = data.investigatorName
            investigatorTitle = data.investigatorTitle
        }
    }

    func save() {
        let dateString = dateFormatter.string(from: investigationDate)

        let result = table.insertOrUpdate(
            patientId: patientId,
            investigationDate: dateString,
            patientName: patientName,
            gender: gender,
            age: Int(age) ?? 0,
            residenceType: residenceType,
            residenceYears: Int(residenceYears) ?? 0,
            address: address,
            height: Double(height) ?? 0,
            weight: Double(weight) ?? 0,
            hasAllergyHistory: hasAllergyHistory,
            allergyDiseases: allergyDiseases.joined(separator: ","),
            currentDiagnoses: currentDiagnoses.joined(separator: ","),
            investigatorName: investigatorName,
            investigatorTitle: investigatorTitle
        )

        if result {
            alertMessage = "保存成功"
        } else {
            alertMessage = "保存失败"
        }
        showAlert = true
    }

    
    var body: some View {
        Form {
            Section(header: Text("调查与患者信息")) {
                DatePicker("调查时间", selection: $investigationDate, displayedComponents: .date)
                TextField("姓名", text: $patientName)
                Picker("性别", selection: $gender) {
                    Text("男").tag("男")
                    Text("女").tag("女")
                }.pickerStyle(SegmentedPickerStyle())
                TextField("年龄", text: $age)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("居住与身体信息")) {
                TextField("居住地类型", text: $residenceType)
                TextField("居住年限", text: $residenceYears)
                    .keyboardType(.numberPad)
                TextField("家庭住址", text: $address)
                TextField("身高 (cm)", text: $height)
                    .keyboardType(.decimalPad)
                TextField("体重 (kg)", text: $weight)
                    .keyboardType(.decimalPad)
            }

            Section(header: Text("过敏史")) {
                Toggle("既往是否有过敏史", isOn: $hasAllergyHistory)
                if hasAllergyHistory {
                    MultipleSelectionView(title: "过敏疾病", options: ["过敏性鼻炎", "支气管哮喘", "特应性皮炎", "过敏性结膜炎", "荨麻疹"], selection: $allergyDiseases)
                }
            }

            Section(header: Text("本次调查诊断")) {
                MultipleSelectionView(title: "诊断", options: ["过敏性鼻炎", "支气管哮喘", "特应性皮炎", "过敏性结膜炎", "荨麻疹"], selection: $currentDiagnoses)
            }

            Section(header: Text("调查人员信息")) {
                TextField("姓名", text: $investigatorName)
                Picker("职称", selection: $investigatorTitle) {
                    Text("住院医师").tag("住院医师")
                    Text("主治医师").tag("主治医师")
                    Text("副主任医师").tag("副主任医师")
                    Text("主任医师").tag("主任医师")
                }
            }

            Button("保存") {
                save()
            }
        }
        .navigationTitle("患儿基本信息")
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        }
        .onAppear {
            load()
        }
    }
}

struct MultipleSelectionView: View {
    let title: String
    let options: [String]
    @Binding var selection: Set<String>

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline)
            ForEach(options, id: \.self) { option in
                Toggle(option, isOn: Binding(
                    get: { selection.contains(option) },
                    set: { isOn in
                        if isOn {
                            selection.insert(option)
                        } else {
                            selection.remove(option)
                        }
                    }
                ))
            }
        }
    }
}

