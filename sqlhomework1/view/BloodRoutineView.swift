//
//  BloodRoutineView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct BloodRoutineView: View {
    let patientId: Int32
    let table = CheckReportsTable(db: DatabaseManager.shared.db)

    @State private var reports: [CheckReport] = []
    @State private var showingAddSheet = false
    @State private var editingReport: CheckReport? = nil
    @State private var showingEditSheet = false

    var body: some View {
        VStack {
            if reports.isEmpty {
                Spacer()
                Text("暂无血常规记录").foregroundColor(.gray)
                Button("添加血常规检查") {
                    showingAddSheet = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                Spacer()
            } else {
                List {
                    ForEach(reports) { report in
                        let dict = parseReportJson(report.reportJson) ?? [:]

                        VStack(alignment: .leading, spacing: 4) {
                            Text("检查日期：\(report.checkDate)")
                                .font(.headline)

                            BloodRoutineFieldsView(dict: dict)

                            if !report.remarks.isEmpty {
                                Text("备注：\(report.remarks)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                table.deleteCheckReport(by: report.id)
                                loadReports()
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                editingReport = report
                                showingEditSheet = true
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("血常规")
        .toolbar {
            Button {
                showingAddSheet = true
            } label: {
                Label("添加", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddReportView(
                patientId: patientId,
                category: "血常规",
                fields: CheckReportFields.bloodRoutineFields
            ) {
                loadReports()
                showingAddSheet = false
            }
        }
        .sheet(item: $editingReport) { report in
            EditReportView(
                report: report,
                category: "血常规",
                fields: CheckReportFields.bloodRoutineFields
            ) {
                loadReports()
                showingEditSheet = false
            }
        }
        .onAppear {
            loadReports()
        }
    }

    func loadReports() {
        reports = table.queryReports(for: patientId)
    }

    func parseReportJson(_ json: String) -> [String: String]? {
        if let data = json.data(using: .utf8) {
            return try? JSONDecoder().decode([String: String].self, from: data)
        }
        return nil
    }
}

struct BloodRoutineFieldsView: View {
    let dict: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(CheckReportFields.bloodRoutineFields, id: \.self) { key in
                if let value = dict[key], !value.isEmpty {
                    Text("\(key)：\(value)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

