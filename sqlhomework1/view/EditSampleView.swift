//
//  EditSampleView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import SwiftUI

struct EditSampleView: View {
    @Environment(\.dismiss) var dismiss

    @State var sampleType: String
    @State var collectionDate: Date
    @State var storageMethod: String
    @State var sampleCode: String

    let sampleId: Int32
    let onSave: () -> Void
    let table = SamplesTable(db: DatabaseManager.shared.db)

    init(sample: Sample, onSave: @escaping () -> Void) {
        _sampleType = State(initialValue: sample.sampleType)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: sample.collectionDate) {
            _collectionDate = State(initialValue: date)
        } else {
            _collectionDate = State(initialValue: Date())
        }

        _storageMethod = State(initialValue: sample.storageMethod)
        _sampleCode = State(initialValue: sample.sampleCode)
        self.sampleId = sample.id
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("样本类型", text: $sampleType)
                DatePicker("采集日期", selection: $collectionDate, displayedComponents: .date)
                TextField("储存方式", text: $storageMethod)
                TextField("样本编号", text: $sampleCode)
            }
            .navigationTitle("编辑样本")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateStr = formatter.string(from: collectionDate)

                        table.updateSample(
                            id: sampleId,
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
