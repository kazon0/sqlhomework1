//
//  AddReportView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct AddReportView: View {
    let patientId: Int32
    let category: String
    let fields: [String]
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var checkDate = Date()
    @State private var remarks = ""
    @State private var values: [String: String] = [:]

    let table = CheckReportsTable(db: DatabaseManager.shared.db)

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("检查日期")) {
                    DatePicker("选择日期", selection: $checkDate, displayedComponents: .date)
                }

                Section(header: Text("检查项目填写")) {
                    ForEach(fields, id: \.self) { field in
                        TextField(field, text: Binding(
                            get: { values[field, default: ""] },
                            set: { values[field] = $0 }
                        ))
                        .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("备注")) {
                    TextField("可选填写", text: $remarks)
                }
            }
            .navigationTitle("添加 \(category)")
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

    func saveReport() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: checkDate)

        let jsonData = try? JSONEncoder().encode(values)
        let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? "{}"

        table.insertCheckReport(
            patientId: patientId,
            category: category,
            subType: "",
            checkDate: dateStr,
            reportJson: jsonString,
            remarks: remarks
        )

        onSave()
        dismiss()
    }
}
