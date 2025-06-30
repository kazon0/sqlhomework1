//
//  AddFollowUpView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//
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

    @State private var symptoms: [Followup.SymptomsInfo.Symptom] = []
    @State private var signs: [Followup.SymptomsInfo.Sign] = []
    @State private var drugReactions: [Followup.DrugReaction] = []

    @State private var doctorFeedback = ""
    @State private var treatments: [Followup.OtherInfo.AuxiliaryTreatment] = []
    @State private var expenses: [Followup.OtherInfo.Expense] = []

    @Environment(\.dismiss) var dismiss
    let table = FollowupTable(db: DatabaseManager.shared.db)
    
    @State private var durationDaysStrings: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("随访日期", selection: $date, displayedComponents: .date)
                Stepper("症状评分：\(score)", value: $score, in: 0...10)

                Section("症状") {
                    ForEach(symptoms.indices, id: \.self) { idx in
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("症状名称", text: Binding(
                                    get: { symptoms[idx].name },
                                    set: { symptoms[idx].name = $0 }
                                ))
                                Spacer()
                                Button(role: .destructive) {
                                    symptoms.remove(at: idx)
                                    durationDaysStrings.remove(at: idx)
                                } label: {
                                    Image(systemName: "x.circle")
                                        .foregroundColor(.red)
                                }
                            }
                            TextField("严重度", text: Binding(
                                get: { symptoms[idx].severity ?? "" },
                                set: { symptoms[idx].severity = $0 }
                            ))
                            TextField("持续天数", text: Binding(
                                get: { durationDaysStrings.indices.contains(idx) ? durationDaysStrings[idx] : "" },
                                set: { newValue in
                                    if durationDaysStrings.indices.contains(idx) {
                                        durationDaysStrings[idx] = newValue
                                    } else if idx == durationDaysStrings.count {
                                        durationDaysStrings.append(newValue)
                                    }
                                    // 转换为Int?，空串为nil，非数字忽略更新
                                    if let intVal = Int(newValue) {
                                        symptoms[idx].durationDays = intVal
                                    } else if newValue.isEmpty {
                                        symptoms[idx].durationDays = nil
                                    }
                                }
                            ))
                        }
                        .padding(.vertical, 4)
                    }
                    Button("添加症状") {
                        symptoms.append(Followup.SymptomsInfo.Symptom(name: "", severity: nil, durationDays: nil))
                        durationDaysStrings.append("")
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("体征") {
                    ForEach(signs.indices, id: \.self) { idx in
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("体征名称", text: Binding(
                                    get: { signs[idx].name },
                                    set: { signs[idx].name = $0 }
                                ))
                                Spacer()
                                Button(role: .destructive) {
                                    signs.remove(at: idx)
                                } label: {
                                    Image(systemName: "x.circle")
                                        .foregroundColor(.red)
                                }
                                .offset(y:-5)
                            }
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
                            HStack{
                                TextField("药品名称", text: Binding(
                                    get: { drugReactions[idx].drugName },
                                    set: { drugReactions[idx].drugName = $0 }
                                ))
                                Spacer()
                                Button(role: .destructive) {
                                    drugReactions.remove(at: idx)
                                } label: {
                                    Image(systemName: "x.circle")
                                        .foregroundColor(.red)
                                }
                            }
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

                Section("辅助治疗") {
                    ForEach(treatments.indices, id: \.self) { idx in
                        VStack(alignment: .leading) {
                            TextField("治疗方法", text: Binding(
                                get: { treatments[idx].treatmentMethod },
                                set: { treatments[idx].treatmentMethod = $0 }
                            ))
                            TextField("开始日期 (YYYY-MM-DD)", text: Binding(
                                get: { treatments[idx].startDate },
                                set: { treatments[idx].startDate = $0 }
                            ))
                            TextField("结束日期 (可为空)", text: Binding(
                                get: { treatments[idx].endDate ?? "" },
                                set: { treatments[idx].endDate = $0.isEmpty ? nil : $0 }
                            ))
                            TextField("备注", text: Binding(
                                get: { treatments[idx].notes ?? "" },
                                set: { treatments[idx].notes = $0.isEmpty ? nil : $0 }
                            ))
                            Button(role: .destructive) {
                                treatments.remove(at: idx)
                            } label: {
                                Text("删除该治疗").foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    Button("添加辅助治疗") {
                        treatments.append(.init(treatmentMethod: "", startDate: "", endDate: nil, notes: nil))
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Section("费用记录") {
                    ForEach(expenses.indices, id: \.self) { idx in
                        VStack(alignment: .leading) {
                            TextField("类别", text: Binding(
                                get: { expenses[idx].category },
                                set: { expenses[idx].category = $0 }
                            ))
                            TextField("金额", value: Binding(
                                get: { expenses[idx].amount },
                                set: { expenses[idx].amount = $0 }
                            ), formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            TextField("发生日期 (YYYY-MM-DD)", text: Binding(
                                get: { expenses[idx].date },
                                set: { expenses[idx].date = $0 }
                            ))
                            Button(role: .destructive) {
                                expenses.remove(at: idx)
                            } label: {
                                Text("删除该记录").foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    Button("添加费用记录") {
                        expenses.append(.init(category: "", amount: 0.0, date: ""))
                    }
                    .buttonStyle(.borderedProminent)
                }

            }
            .navigationTitle("添加随访记录")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = formatter.string(from: date)

                        let symptomsInfo = Followup.SymptomsInfo(symptoms: symptoms, signs: signs)
                        let otherInfo = Followup.OtherInfo(auxiliaryTreatments: nil, expenses: nil)

                        let success = table.insertFollowup(
                            patientId: patientId,
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
