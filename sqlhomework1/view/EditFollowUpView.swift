//
//  EditFollowUpView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import SwiftUI

struct EditFollowUpView: View {
    let followup: Followup
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var date: Date
    @State private var score: Int
    @State private var reaction: String
    @State private var feedback: String

    let table = FollowupTable(db: DatabaseManager.shared.db)

    init(followup: Followup, onSave: @escaping () -> Void) {
        self.followup = followup
        self.onSave = onSave
        _reaction = State(initialValue: followup.drugReaction)
        _feedback = State(initialValue: followup.doctorFeedback)
        _score = State(initialValue: Int(followup.symptomScore))

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        _date = State(initialValue: formatter.date(from: followup.followupDate) ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("随访日期", selection: $date, displayedComponents: .date)
                Stepper("症状评分：\(score)", value: $score, in: 0...10)
                TextField("药物反应", text: $reaction)
                TextField("医生反馈", text: $feedback)
            }
            .navigationTitle("编辑随访记录")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateStr = formatter.string(from: date)
                        table.updateFollowup(id: followup.id, date: dateStr, score: Int32(score), reaction: reaction, feedback: feedback)
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
