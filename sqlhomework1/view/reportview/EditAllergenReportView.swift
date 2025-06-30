//
//  EditAllergenReportView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct EditAllergenReportView: View {
    let report: CheckReport
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var checkDate: Date
    @State private var remarks: String

    // [过敏原名: (value: String, conclusion: String)]
    @State private var selectedFields: [String: (value: String, conclusion: String)] = [:]

    let conclusions = ["阴性", "弱阳性", "阳性", "强阳性", "未判定"]

    let table = CheckReportsTable(db: DatabaseManager.shared.db)

    init(report: CheckReport, onSave: @escaping () -> Void) {
        self.report = report
        self.onSave = onSave
        _checkDate = State(initialValue: Self.parseDate(from: report.checkDate))
        _remarks = State(initialValue: report.remarks)

        if let data = report.reportJson.data(using: .utf8),
           let dict = try? JSONDecoder().decode([String: [String: String]].self, from: data) {
            var temp: [String: (String, String)] = [:]
            for (key, valueDict) in dict {
                let value = valueDict["value"] ?? ""
                let conclusion = valueDict["conclusion"] ?? "阴性"
                temp[key] = (value, conclusion)
            }
            _selectedFields = State(initialValue: temp)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("检查日期")) {
                    DatePicker("选择日期", selection: $checkDate, displayedComponents: .date)
                }

                Section(header: Text("IgE组合")) {
                    ForEach(CheckReportFields.igEFields, id: \.self) { field in
                        allergenRow(field: field)
                    }
                }

                Section(header: Text("单项过敏原")) {
                    ForEach(CheckReportFields.allergenSingleFields, id: \.self) { field in
                        allergenRow(field: field)
                    }
                }

                Section(header: Text("备注")) {
                    TextEditor(text: $remarks)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("编辑过敏原检查")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveReport()
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

    @ViewBuilder
    private func allergenRow(field: String) -> some View {
        VStack(alignment: .leading) {
            Text(field).font(.headline)
            TextField("检查值（kU/L）", text: Binding(
                get: { selectedFields[field]?.value ?? "" },
                set: { newValue in
                    var old = selectedFields[field] ?? ("", "阴性")
                    old.value = newValue
                    selectedFields[field] = old
                }
            ))
            .keyboardType(.decimalPad)
            Picker("判定结果", selection: Binding(
                get: { selectedFields[field]?.conclusion ?? "阴性" },
                set: { newValue in
                    var old = selectedFields[field] ?? ("", "阴性")
                    old.conclusion = newValue
                    selectedFields[field] = old
                }
            )) {
                ForEach(conclusions, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 4)
    }

    func saveReport() {
        let dateString = Self.formatDate(date: checkDate)

        var dictToSave: [String: [String: String]] = [:]
        for (key, tuple) in selectedFields {
            // 只保存非空项，或者你想保存全部
            if !tuple.value.isEmpty || !tuple.conclusion.isEmpty {
                dictToSave[key] = ["value": tuple.value, "conclusion": tuple.conclusion]
            }
        }

        guard let jsonData = try? JSONEncoder().encode(dictToSave),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("JSON编码失败")
            return
        }

        table.updateCheckReport(
            id: report.id,
            category: report.category,
            subType: report.subType,
            checkDate: dateString,
            reportJson: jsonString,
            remarks: remarks
        )

        onSave()
        dismiss()
    }

    static func parseDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string) ?? Date()
    }

    static func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
