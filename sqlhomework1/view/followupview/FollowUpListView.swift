//
//  FollowUpListView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

struct FollowUpListView: View {
    let patientId: Int32
    let table = FollowupTable(db: DatabaseManager.shared.db)

    @State private var followups: [Followup] = []
    @State private var showingAddSheet = false
    @State private var editingFollowup: Followup? = nil

    var body: some View {
        VStack {
            if followups.isEmpty {
                Spacer()
                Text("暂无随访记录")
                    .foregroundColor(.gray)
                    .italic()
                Button("添加记录") {
                    showingAddSheet = true
                }
                .padding()
                .background(Color.orange.gradient)
                .foregroundColor(.white)
                .cornerRadius(12)
                Spacer()
            } else {
                List {
                    ForEach(followups) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("随访时间：\(item.followupDate)").bold()
                            Text("症状评分：\(item.symptomScore)")

                            if let symptoms = item.symptomsJson?.symptoms, !symptoms.isEmpty {
                                Text("症状：").bold()
                                ForEach(symptoms.indices, id: \.self) { i in
                                    let s = symptoms[i]
                                    Text("- \(s.name) | 严重度: \(s.severity ?? "无") | 持续 \(s.durationDays.map { "\($0)天" } ?? "未知")")
                                        .font(.subheadline)
                                }
                            }

                            if let signs = item.symptomsJson?.signs, !signs.isEmpty {
                                Text("体征：").bold()
                                ForEach(signs.indices, id: \.self) { i in
                                    let s = signs[i]
                                    Text("- \(s.name) | 存在: \(s.present == true ? "是" : "否") | 值: \(s.value ?? "无")")
                                        .font(.subheadline)
                                }
                            }

                            if let reactions = item.drugReactionJson, !reactions.isEmpty {
                                Text("药物不良反应：").bold()
                                ForEach(reactions.indices, id: \.self) { i in
                                    let r = reactions[i]
                                    Text("- \(r.drugName):")
                                        .font(.subheadline)
                                    Text("  反应时间: \(r.reactionDate)，剂量: \(r.dosage)，持续 \(r.durationDays) 天")
                                        .font(.subheadline)
                                    Text("  症状: \(r.symptoms.joined(separator: ", "))，严重度: \(r.severity)")
                                        .font(.subheadline)
                                }
                            } else {
                                Text("药物不良反应：无")
                                    .italic()
                            }

                            Text("医生反馈：\(item.doctorFeedback.isEmpty ? "无" : item.doctorFeedback)")
                                .padding(.top, 4)

                            if let treatments = item.otherInfoJson?.auxiliaryTreatments, !treatments.isEmpty {
                                Text("辅助治疗：").bold()
                                ForEach(treatments.indices, id: \.self) { i in
                                    let t = treatments[i]
                                    Text("- \(t.treatmentMethod) | \(t.startDate) 至 \(t.endDate ?? "至今")")
                                        .font(.subheadline)
                                    if let notes = t.notes, !notes.isEmpty {
                                        Text("  备注：\(notes)")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            if let expenses = item.otherInfoJson?.expenses, !expenses.isEmpty {
                                Text("费用记录：").bold()
                                ForEach(expenses.indices, id: \.self) { i in
                                    let e = expenses[i]
                                    Text("- \(e.category)：¥\(String(format: "%.2f", e.amount))，日期：\(e.date)")
                                        .font(.subheadline)
                                }
                            }

                        }
                        .padding(.vertical, 6)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                _ = table.deleteFollowup(by: item.id)
                                followups = table.queryFollowups(for: patientId)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                editingFollowup = item
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }

            }
        }
        .navigationTitle("随访记录")
        .toolbar {
            Button {
                showingAddSheet = true
            } label: {
                Label("添加", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddFollowUpView(patientId: patientId) {
                followups = table.queryFollowups(for: patientId)
                showingAddSheet = false
            }
        }
        .sheet(item: $editingFollowup) { followup in
            EditFollowUpView(followup: followup) {
                followups = table.queryFollowups(for: patientId)
                editingFollowup = nil
            }
        }
        .onAppear {
            followups = table.queryFollowups(for: patientId)
        }
    }
}
