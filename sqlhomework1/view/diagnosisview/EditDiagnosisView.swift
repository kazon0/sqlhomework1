//
//  EditDiagnosisView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//
import SwiftUI

struct EditDiagnosisView: View {
    @Environment(\.dismiss) var dismiss

    let diagnosisId: Int32
    let onSave: () -> Void
    let diagnosisTable = DiagnosisTable(db: DatabaseManager.shared.db)

    @State private var diseaseType: String
    @State private var customName: String
    @State private var visitDate: Date
    @State private var allergens: String

    // 用药治疗拆成主要治疗和辅助治疗两部分
    @State private var selectedMainTreatments: Set<String> = []
    @State private var selectedAdjunctTreatments: Set<String> = []

    // 症状模型，默认空，需要解析 JSON 填充
    @State private var asthmaSymptoms = AsthmaSymptomData()
    @State private var rhinitisSymptoms = RhinitisSymptomData()
    @State private var dermatitisSymptoms = DermatitisSymptomData()
    @State private var otherSymptomsText = ""

    // 解析传入的 Diagnosis 结构体初始化时用
    init(diagnosis: Diagnosis, onSave: @escaping () -> Void) {
        self.diagnosisId = diagnosis.id
        self.onSave = onSave

        // 解析日期字符串
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: diagnosis.visitDate) {
            _visitDate = State(initialValue: date)
        } else {
            _visitDate = State(initialValue: Date())
        }

        _diseaseType = State(initialValue: diagnosis.diseaseType)
        _customName = State(initialValue: diagnosis.customName)
        _allergens = State(initialValue: diagnosis.allergens)

        _selectedMainTreatments = State(initialValue: [])
        _selectedAdjunctTreatments = State(initialValue: [])


        // 尝试解析症状 JSON
        if diagnosis.diseaseType == "哮喘" {
            if let data = diagnosis.symptomJson.data(using: .utf8),
               let symptoms = try? JSONDecoder().decode(AsthmaSymptomData.self, from: data) {
                _asthmaSymptoms = State(initialValue: symptoms)
            }
        } else if diagnosis.diseaseType == "过敏性鼻炎" {
            if let data = diagnosis.symptomJson.data(using: .utf8),
               let symptoms = try? JSONDecoder().decode(RhinitisSymptomData.self, from: data) {
                _rhinitisSymptoms = State(initialValue: symptoms)
            }
        } else if diagnosis.diseaseType == "湿疹" {
            if let data = diagnosis.symptomJson.data(using: .utf8),
               let symptoms = try? JSONDecoder().decode(DermatitisSymptomData.self, from: data) {
                _dermatitisSymptoms = State(initialValue: symptoms)
            }
        } else {
            _otherSymptomsText = State(initialValue: diagnosis.symptomJson)
        }

        // 解析 treatment 字符串为已选集合
        // 假设 treatment 格式：主要治疗 + ";" + 辅助治疗，或者全部分号分隔
        let treatments = diagnosis.treatment.split(separator: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        var mainSet = Set<String>()
        var adjunctSet = Set<String>()
        for t in treatments {
            if mainTreatmentOptions[diagnosis.diseaseType]?.contains(t) == true {
                mainSet.insert(t)
            } else if adjunctTreatmentOptions.contains(t) {
                adjunctSet.insert(t)
            }
        }
        _selectedMainTreatments = State(initialValue: mainSet)
        _selectedAdjunctTreatments = State(initialValue: adjunctSet)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("诊断类型")) {
                    Picker("诊断类型", selection: $diseaseType) {
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
                        TextEditor(text: $otherSymptomsText)
                            .frame(minHeight: 100)
                            .border(Color.gray.opacity(0.3))
                    }
                }

                // 主要治疗多选
                if let mainOptions = mainTreatmentOptions[diseaseType] {
                    Section(header: Text("主要治疗")) {
                        ForEach(mainOptions, id: \.self) { option in
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

                // 辅助治疗多选（固定）
                Section(header: Text("辅助治疗")) {
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
            .navigationTitle("编辑诊断记录")
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
            .onChange(of: diseaseType) { oldValue, newValue in
                if oldValue != newValue {
                    selectedMainTreatments = []
                    selectedAdjunctTreatments = []
                }
            }
        }
    }

    var canSave: Bool {
        if diseaseType == "其他" {
            return !customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !otherSymptomsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    func saveDiagnosis() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let visitDateStr = formatter.string(from: visitDate)

        let encoder = JSONEncoder()
        var symptomJson = ""

        do {
            switch diseaseType {
            case "哮喘":
                symptomJson = String(data: try encoder.encode(asthmaSymptoms), encoding: .utf8) ?? ""
            case "过敏性鼻炎":
                symptomJson = String(data: try encoder.encode(rhinitisSymptoms), encoding: .utf8) ?? ""
            case "湿疹":
                symptomJson = String(data: try encoder.encode(dermatitisSymptoms), encoding: .utf8) ?? ""
            case "其他":
                symptomJson = otherSymptomsText
            default:
                symptomJson = ""
            }
        } catch {
            print("症状编码失败: \(error.localizedDescription)")
            symptomJson = ""
        }

        // 合并主要治疗和辅助治疗为字符串，用分号分隔
        let allTreatments = (selectedMainTreatments.sorted() + selectedAdjunctTreatments.sorted()).joined(separator: "; ")

        diagnosisTable.updateDiagnosis(
            id: diagnosisId,
            diseaseType: diseaseType,
            customName: diseaseType == "其他" ? customName : nil,
            visitDate: visitDateStr,
            allergens: allergens,
            treatment: allTreatments,
            symptomJson: symptomJson
        )
        onSave()
        dismiss()
    }
}
