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

    @State private var sampleType = "血液"
    @State private var customSampleType = ""
    @State private var collectionDate = Date()
    @State private var storageMethod = ""

    // 自动生成编号（一次性）
    let sampleCode: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return "S-\(Int.random(in: 1000...9999))-\(formatter.string(from: Date()))"
    }()

    var finalSampleType: String {
        sampleType == "其他" ? customSampleType : sampleType
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("样本类型")) {
                    Picker("选择类型", selection: $sampleType) {
                        ForEach(["血液", "唾液", "尿液", "粪便", "鼻拭子", "咽拭子", "皮肤样本", "其他"], id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)

                    if sampleType == "其他" {
                        TextField("请输入自定义样本类型", text: $customSampleType)
                    }
                }

                Section(header: Text("采集信息")) {
                    DatePicker("采集日期", selection: $collectionDate, displayedComponents: .date)
                    TextField("储存方式", text: $storageMethod)
                }

                Section(header: Text("样本编号")) {
                    Text(sampleCode)
                        .foregroundColor(.gray)
                        .font(.callout)
                }
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
                            sampleType: finalSampleType,
                            collectionDate: dateStr,
                            storageMethod: storageMethod,
                            sampleCode: sampleCode
                        )
                        onSave()
                        dismiss()
                    }
                    .disabled(finalSampleType.trimmingCharacters(in: .whitespaces).isEmpty ||
                              storageMethod.trimmingCharacters(in: .whitespaces).isEmpty)
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
