//
//  EditSampleView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

struct EditSampleView: View {
    @Environment(\.dismiss) var dismiss

    @State private var sampleType: String
    @State private var customSampleType: String = ""
    @State private var collectionDate: Date
    @State private var storageMethod: String
    @State private var sampleCode: String

    let sampleId: Int32
    let onSave: () -> Void
    let table = SamplesTable(db: DatabaseManager.shared.db)

    let sampleTypes = ["血液", "唾液", "尿液", "粪便", "鼻拭子", "咽拭子", "皮肤样本", "其他"]

    init(sample: Sample, onSave: @escaping () -> Void) {
        let knownTypes = ["血液", "唾液", "尿液", "粪便", "鼻拭子", "咽拭子", "皮肤样本"]
        if knownTypes.contains(sample.sampleType) {
            _sampleType = State(initialValue: sample.sampleType)
            _customSampleType = State(initialValue: "")
        } else {
            _sampleType = State(initialValue: "其他")
            _customSampleType = State(initialValue: sample.sampleType)
        }

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

    var finalSampleType: String {
        sampleType == "其他" ? customSampleType : sampleType
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("样本类型")) {
                    Picker("选择类型", selection: $sampleType) {
                        ForEach(sampleTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(.menu)

                    if sampleType == "其他" {
                        TextField("请输入自定义类型", text: $customSampleType)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                DatePicker("采集日期", selection: $collectionDate, displayedComponents: .date)
                TextField("储存方式", text: $storageMethod)
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
                            sampleType: finalSampleType,
                            collectionDate: dateStr,
                            storageMethod: storageMethod,
                            sampleCode: sampleCode
                        )
                        onSave()
                        dismiss()
                    }
                    .disabled(finalSampleType.isEmpty || storageMethod.isEmpty || sampleCode.isEmpty)
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
