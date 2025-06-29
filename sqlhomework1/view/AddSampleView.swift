//
//  AddSampleView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import SwiftUI

struct AddSampleView: View {
    @Environment(\.dismiss) var dismiss

    let patientId: Int32
    let onSave: () -> Void
    let table = SamplesTable(db: DatabaseManager.shared.db)

    @State private var sampleType = ""
    @State private var collectionDate = Date()
    @State private var storageMethod = ""
    @State private var sampleCode = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("样本类型", text: $sampleType)
                DatePicker("采集日期", selection: $collectionDate, displayedComponents: .date)
                TextField("储存方式", text: $storageMethod)
                TextField("样本编号", text: $sampleCode)
            }
            .navigationTitle("添加样本")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateStr = formatter.string(from: collectionDate)

                        table.insertSample(
                            patientId: patientId,
                            sampleType: sampleType,
                            collectionDate: dateStr,
                            storageMethod: storageMethod,
                            sampleCode: sampleCode
                        )
                        onSave()
                        dismiss()
                    }
                    .disabled(sampleType.isEmpty || storageMethod.isEmpty || sampleCode.isEmpty)
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
