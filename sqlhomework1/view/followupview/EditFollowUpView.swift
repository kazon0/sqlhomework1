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

    @State private var symptoms: [Followup.SymptomsInfo.Symptom]
    @State private var signs: [Followup.SymptomsInfo.Sign]
    @State private var drugReactions: [Followup.DrugReaction]

    @State private var doctorFeedback: String
    @State private var otherNotes: String

    let table = FollowupTable(db: DatabaseManager.shared.db)

    init(followup: Followup, onSave: @escaping () -> Void) {
        self.followup = followup
        self.onSave = onSave

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        _date = State(initialValue: formatter.date(from: followup.followupDate) ?? Date())
        _score = State(initialValue: Int(followup.symptomScore))
        _symptoms = State(initialValue: followup.symptomsJson?.symptoms ?? [])
        _signs = State(initialValue: followup.symptomsJson?.signs ?? [])
        _drugReactions = State(initialValue: followup.drugReactionJson ?? [])
        _doctorFeedback = State(initialValue: followup.doctorFeedback)
        // 这里如果你有 otherInfoJson 里备注字段，可以初始化
        _otherNotes = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("随访日期", selection: $date, displayedComponents: .date)
                Stepper("症状评分：\(score)", value: $score, in: 0...10)

                Section("症状") {
                    ForEach(symptoms.indices, id: \.self) { idx in
                        VStack(alignment: .leading) {
                            TextField("症状名称", text: Binding(
                                get: { symptoms[idx].name },
                                set: { symptoms[idx].name = $0 }
                            ))
                            TextField("严重度", text: Binding(
                                get: { symptoms[idx].severity ?? "" },
                                set: { symptoms[idx].severity = $0 }
                            ))
                            TextField("持续天数", value: Binding(
                                get: { symptoms[idx].durationDays ?? 0 },
                                set: { symptoms[idx].durationDays = $0 }
                            ), formatter: NumberFormatter())
                        }
                        .padding(.vertical, 4)
                    }
                    Button("添加症状") {
                        symptoms.append(Followup.SymptomsInfo.Symptom(name: "", severity: nil, durationDays: nil))
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("体征") {
                    ForEach(signs.indices, id: \.self) { idx in
                        VStack(alignment: .leading) {
                            TextField("体征名称", text: Binding(
                                get: { signs[idx].name },
                                set: { signs[idx].name = $0 }
                            ))
                            Toggle("是否存在", isOn: Binding(
                                get: { signs[idx].present ?? false },
                                set: { signs[idx].present = $0 }
                            ))
                            TextField("值", text: Binding(
                                get: { signs[idx].value ?? "" },
                                set: { signs[idx].value = $0 }
                            ))
                        }
                        .padding(.vertical, 4)
                    }
                    Button("添加体征") {
                        signs.append(Followup.SymptomsInfo.Sign(name: "", present: nil, value: nil))
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("药物不良反应") {
                    ForEach(drugReactions.indices, id: \.self) { idx in
                        VStack(alignment: .leading) {
                            TextField("药品名称", text: Binding(
                                get: { drugReactions[idx].drugName },
                                set: { drugReactions[idx].drugName = $0 }
                            ))
                            TextField("反应日期 (YYYY-MM-DD)", text: Binding(
                                get: { drugReactions[idx].reactionDate },
                                set: { drugReactions[idx].reactionDate = $0 }
                            ))
                            TextField("剂量", text: Binding(
                                get: { drugReactions[idx].dosage },
                                set: { drugReactions[idx].dosage = $0 }
                            ))
                            TextField("持续天数", value: Binding(
                                get: { drugReactions[idx].durationDays },
                                set: { drugReactions[idx].durationDays = $0 }
                            ), formatter: NumberFormatter())
                            TextField("症状 (逗号分隔)", text: Binding(
                                get: { drugReactions[idx].symptoms.joined(separator: ", ") },
                                set: {
                                    drugReactions[idx].symptoms = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                                }
                            ))
                            TextField("严重度", text: Binding(
                                get: { drugReactions[idx].severity },
                                set: { drugReactions[idx].severity = $0 }
                            ))
                            Button(role: .destructive) {
                                drugReactions.remove(at: idx)
                            } label: {
                                Text("删除该反应")
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 6)
                    }
                    Button("添加药物反应") {
                        drugReactions.append(Followup.DrugReaction(drugName: "", reactionDate: "", dosage: "", durationDays: 0, symptoms: [], severity: ""))
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("医生反馈") {
                    TextEditor(text: $doctorFeedback)
                        .frame(height: 100)
                }

                Section("其他备注") {
                    TextEditor(text: $otherNotes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("编辑随访记录")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = formatter.string(from: date)

                        let symptomsInfo = Followup.SymptomsInfo(symptoms: symptoms, signs: signs)
                        // 这里暂不支持其他辅助治疗和费用，otherNotes作为备注放入
                        let otherInfo = Followup.OtherInfo(auxiliaryTreatments: nil, expenses: nil)

                        let success = table.updateFollowup(
                            id: followup.id,
                            followupDate: dateString,
                            symptomScore: Int32(score),
                            symptomsJson: symptomsInfo,
                            drugReactionJson: drugReactions,
                            doctorFeedback: doctorFeedback,
                            otherInfoJson: otherInfo
                        )
                        if success {
                            onSave()
                            dismiss()
                        } else {
                            // 这里你可以弹提示框显示失败
                        }
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
