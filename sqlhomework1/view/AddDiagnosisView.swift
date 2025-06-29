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

    @State private var diagnosis = ""
    @State private var visitDate = Date()
    @State private var allergens = ""
    @State private var treatment = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("诊断信息")) {
                    TextField("诊断名称", text: $diagnosis)
                    DatePicker("就诊日期", selection: $visitDate, displayedComponents: .date)
                    TextField("过敏原", text: $allergens)
                    TextField("治疗方案", text: $treatment)
                }
            }
            .navigationTitle("添加诊断记录")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        // 日期转字符串
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let visitDateStr = formatter.string(from: visitDate)

                        diagnosisTable.insertDiagnosis(
                            patientId: patientId,
                            diagnosis: diagnosis,
                            visitDate: visitDateStr,
                            allergens: allergens,
                            treatment: treatment
                        )
                        onSave()
                        dismiss()
                    }
                    .disabled(diagnosis.isEmpty) // 必填校验
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}
