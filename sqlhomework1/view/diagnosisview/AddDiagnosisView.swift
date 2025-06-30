//
//  AddDiagnosisView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

struct AddDiagnosisView: View {
    @Environment(\.dismiss) var dismiss

    let patientId: Int32
    let onSave: () -> Void
    let diagnosisTable = DiagnosisTable(db: DatabaseManager.shared.db)

    // 诊断类型
    @State private var diseaseType = "哮喘"

    @State private var customName = ""

    // 就诊日期
    @State private var visitDate = Date()
    
    @State private var allergens = ""
    
    // 选中的主要治疗方案
    @State private var selectedMainTreatments: Set<String> = []

    // 选中的辅助治疗方案
    @State private var selectedAdjunctTreatments: Set<String> = []

    // 自定义主要治疗文本（当选择“其他”时）
    @State private var customMainTreatment: String = ""


    // 各症状模型
    @State private var asthmaSymptoms = AsthmaSymptomData()
    @State private var rhinitisSymptoms = RhinitisSymptomData()
    @State private var dermatitisSymptoms = DermatitisSymptomData()

    @State private var otherSymptomsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("诊断类型")) {
                    Picker("请选择诊断类型", selection: $diseaseType) {
                        ForEach(diseaseTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    if diseaseType == "其他" {
                        TextField("自定义诊断名称", text: $customName)
                    }
                }

                Section(header: Text("就诊日期")) {
                    DatePicker("选择日期", selection: $visitDate, displayedComponents: .date)
                }

                Section(header: Text("症状")) {
                    if diseaseType == "哮喘" {
                        Toggle("喘息", isOn: $asthmaSymptoms.wheezing)
                        Toggle("咳嗽", isOn: $asthmaSymptoms.coughing)
                        Toggle("胸闷", isOn: $asthmaSymptoms.chestTightness)
                    } else if diseaseType == "过敏性鼻炎" {
                        Toggle("流清水鼻涕", isOn: $rhinitisSymptoms.runnyNose)
                        Toggle("阵发性喷嚏", isOn: $rhinitisSymptoms.sneezing)
                        Toggle("鼻塞", isOn: $rhinitisSymptoms.nasalCongestion)
                    } else if diseaseType == "湿疹" {
                        Toggle("皮肤干燥", isOn: $dermatitisSymptoms.drySkin)
                        Toggle("复发性瘙痒性皮疹", isOn: $dermatitisSymptoms.eczemaHistory)
                        Toggle("有皮肤感染倾向", isOn: $dermatitisSymptoms.skinInfection)
                    } else {
                        TextField("请描述症状", text: $otherSymptomsText, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }

                Section(header: Text("主要治疗方案")) {
                    if diseaseType == "其他" {
                        TextField("请输入主要治疗方案", text: $customMainTreatment, axis: .vertical)
                            .lineLimit(3...6)
                    } else {
                        let options = mainTreatmentOptions[diseaseType] ?? []
                        ForEach(options, id: \.self) { option in
                            MultipleSelectionRow(title: option, isSelected: selectedMainTreatments.contains(option)) {
                                if selectedMainTreatments.contains(option) {
                                    selectedMainTreatments.remove(option)
                                } else {
                                    selectedMainTreatments.insert(option)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("辅助治疗方案")) {
                    ForEach(adjunctTreatmentOptions, id: \.self) { option in
                        MultipleSelectionRow(title: option, isSelected: selectedAdjunctTreatments.contains(option)) {
                            if selectedAdjunctTreatments.contains(option) {
                                selectedAdjunctTreatments.remove(option)
                            } else {
                                selectedAdjunctTreatments.insert(option)
                            }
                        }
                    }
                }

            }
            .navigationTitle("添加诊断记录")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveDiagnosis()
                    }
                    .disabled(!canSave)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    // 是否满足保存条件
    var canSave: Bool {
        if diseaseType == "其他" {
            return !customName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !otherSymptomsText.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return true
    }

    func saveDiagnosis() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let visitDateStr = formatter.string(from: visitDate)

        // 生成症状 JSON
        let encoder = JSONEncoder()
        var symptomJson = ""

        do {
            if diseaseType == "哮喘" {
                symptomJson = String(data: try encoder.encode(asthmaSymptoms), encoding: .utf8) ?? ""
            } else if diseaseType == "过敏性鼻炎" {
                symptomJson = String(data: try encoder.encode(rhinitisSymptoms), encoding: .utf8) ?? ""
            } else if diseaseType == "湿疹" {
                symptomJson = String(data: try encoder.encode(dermatitisSymptoms), encoding: .utf8) ?? ""
            } else {
                symptomJson = otherSymptomsText
            }
        } catch {
            print("症状编码失败: \(error)")
        }

        // 主要治疗方案
        let mainTreatment: String
        if diseaseType == "其他" {
            mainTreatment = customMainTreatment.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            mainTreatment = selectedMainTreatments.sorted().joined(separator: "；")
        }

        // 辅助治疗方案
        let adjunctTreatment = selectedAdjunctTreatments.sorted().joined(separator: "；")

        // 拼接完整治疗方案
        let treatmentFull = mainTreatment + (adjunctTreatment.isEmpty ? "" : "；" + adjunctTreatment)

        // 其他业务逻辑...
        diagnosisTable.insertDiagnosis(
            patientId: patientId,
            visitDate: visitDateStr,
            diseaseType: diseaseType,
            customName: diseaseType == "其他" ? customName : nil,
            allergens: allergens,
            treatment: treatmentFull,
            symptomJson: symptomJson
        )

        onSave()
        dismiss()
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

