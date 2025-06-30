//
//  EditReportView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct EditReportView: View {
    @Environment(\.dismiss) var dismiss

    let report: CheckReport
    let category: String
    let fields: [String]
    let onSave: () -> Void

    @State private var values: [String: String] = [:]
    @State private var checkDate: Date = Date()
    @State private var remarks: String = ""

    let table = CheckReportsTable(db: DatabaseManager.shared.db)

    init(report: CheckReport, category: String, fields: [String], onSave: @escaping () -> Void) {
        self.report = report
        self.category = category
        self.fields = fields
        self.onSave = onSave

        // 初始化日期和备注
        if let date = DateFormatter.yyyyMMdd.date(from: report.checkDate) {
            _checkDate = State(initialValue: date)
        }
        _remarks = State(initialValue: report.remarks)

        // 初始化字段值（从 JSON 解析）
        if let data = report.reportJson.data(using: .utf8),
           let dict = try? JSONDecoder().decode([String: String].self, from: data) {
            _values = State(initialValue: dict)
        } else {
            _values = State(initialValue: Dictionary(uniqueKeysWithValues: fields.map { ($0, "") }))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("检查日期")) {
                    DatePicker("检查日期", selection: $checkDate, displayedComponents: .date)
                }

                Section(header: Text("检查结果")) {
                    ForEach(fields, id: \.self) { field in
                        TextField(field, text: Binding(
                            get: { values[field] ?? "" },
                            set: { values[field] = $0 }
                        ))
                        .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("备注")) {
                    TextField("备注", text: $remarks)
                }
            }
            .navigationTitle("编辑检查报告")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
                    }
                }
            }
        }
    }

    func saveChanges() {
        let formatter = DateFormatter.yyyyMMdd
        let dateString = formatter.string(from: checkDate)

        let jsonData = try? JSONEncoder().encode(values)
        let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? "{}"

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
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
