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
                            Text("时间：\(item.followupDate)").bold()
                            Text("症状评分：\(item.symptomScore)")
                            Text("药物反应：\(item.drugReaction)")
                            Text("医生反馈：\(item.doctorFeedback)")
                        }
                        .padding(.vertical, 6)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                table.deleteFollowup(by: item.id)
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
