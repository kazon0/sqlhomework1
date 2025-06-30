//
//  EditLungFunctionReportView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct EditLungFunctionReportView: View {
    let report: CheckReport
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var selectedSubType: String
    @State private var checkDate: Date
    @State private var remarks: String
    @State private var fieldValues: [String: String] = [:]

    let subTypes = [
        "常规肺功能",
        "支气管舒张试验",
        "支气管激发试验",
        "潮气肺功能检查"
    ]

    let table = CheckReportsTable(db: DatabaseManager.shared.db)

    // 依据 selectedSubType 获取对应字段数组
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

    init(report: CheckReport, onSave: @escaping () -> Void) {
        self.report = report
        self.onSave = onSave

        // 初始化状态变量
        _selectedSubType = State(initialValue: report.subType)
        _remarks = State(initialValue: report.remarks)

        // 解析日期字符串到 Date 类型
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: report.checkDate) {
            _checkDate = State(initialValue: date)
        } else {
            _checkDate = State(initialValue: Date())
        }

        // 解析 JSON 字符串为字典
        if let data = report.reportJson.data(using: .utf8),
           let dict = try? JSONDecoder().decode([String: String].self, from: data) {
            _fieldValues = State(initialValue: dict)
        } else {
            _fieldValues = State(initialValue: [:])
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
            .navigationTitle("编辑肺功能检查")
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

        table.updateCheckReport(
            id: report.id,
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
