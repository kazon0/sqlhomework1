//
//  AddFollowUpView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import SwiftUI

struct AddFollowUpView: View {
    let patientId: Int32
    let onSave: () -> Void

    @State private var date = Date()
    @State private var score = 0
    @State private var reaction = ""
    @State private var feedback = ""

    let table = FollowupTable(db: DatabaseManager.shared.db)
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("随访日期", selection: $date, displayedComponents: .date)
                Stepper("症状评分：\(score)", value: $score, in: 0...10)
                TextField("药物反应", text: $reaction)
                TextField("医生反馈", text: $feedback)
            }
            .navigationTitle("添加随访记录")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = formatter.string(from: date)
                        table.insertFollowup(patientId: patientId, followupDate: dateString, symptomScore: Int32(score), drugReaction: reaction, doctorFeedback: feedback)
                        onSave()
                        dismiss()
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
}
