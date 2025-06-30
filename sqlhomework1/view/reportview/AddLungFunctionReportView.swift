//
//  AddLungFunctionReportView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct AddLungFunctionReportView: View {
    let patientId: Int32
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var selectedSubType = "常规肺功能"
    @State private var checkDate = Date()
    @State private var remarks = ""
    @State private var fieldValues: [String: String] = [:]

    let subTypes = [
        "常规肺功能",
        "支气管舒张试验",
        "支气管激发试验",
        "潮气肺功能检查"
    ]

    let table = CheckReportsTable(db: DatabaseManager.shared.db)

    var currentFields: [String] {
        switch selectedSubType {
        case "常规肺功能":
            return CheckReportFields.lungFunctionFields
        case "支气管舒张试验":
            return CheckReportFields.bronchodilatorTestFields
        case "支气管激发试验":
            return CheckReportFields.bronchialProvocationTestFields
        case "潮气肺功能检查":
            return CheckReportFields.tidalLungFunctionFields
        default:
            return []
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("检查子类型") {
                    Picker("选择检查类型", selection: $selectedSubType) {
                        ForEach(subTypes, id: \.self) { Text($0) }
                    }
                }

                Section("检查日期") {
                    DatePicker("选择日期", selection: $checkDate, displayedComponents: .date)
                }

                Section("检查项目填写") {
                    ForEach(currentFields, id: \.self) { field in
                        if selectedSubType == "支气管舒张试验" || selectedSubType == "支气管激发试验" {
                            Picker(field, selection: Binding(
                                get: { fieldValues[field, default: "阴性"] },
                                set: { fieldValues[field] = $0 }
                            )) {
                                Text("阴性").tag("阴性")
                                Text("阳性").tag("阳性")
                            }
                            .pickerStyle(.segmented)
                        } else {
                            TextField(field, text: Binding(
                                get: { fieldValues[field, default: ""] },
                                set: { fieldValues[field] = $0 }
                            ))
                            .keyboardType(.decimalPad)
                        }
                    }
                }

                Section("备注") {
                    TextEditor(text: $remarks)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("新增肺功能检查")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveReport()
                    }
                    .disabled(currentFields.allSatisfy { fieldValues[$0]?.isEmpty ?? true })
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    func saveReport() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: checkDate)

        guard let jsonData = try? JSONEncoder().encode(fieldValues),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("JSON 编码失败")
            return
        }

        table.insertCheckReport(
            patientId: patientId,
            category: "肺功能",
            subType: selectedSubType,
            checkDate: dateString,
            reportJson: jsonString,
            remarks: remarks
        )

        onSave()
        dismiss()
    }
}
