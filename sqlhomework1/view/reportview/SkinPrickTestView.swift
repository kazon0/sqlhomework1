//
//  SkinPrickTestView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct SkinPrickTestView: View {
    let patientId: Int32
    let table = CheckReportsTable(db: DatabaseManager.shared.db)

    @State private var reports: [CheckReport] = []
    @State private var showingAddSheet = false
    @State private var editingReport: CheckReport? = nil

    var body: some View {
        VStack {
            if reports.isEmpty {
                Spacer()
                Text("暂无皮肤点刺记录").foregroundColor(.gray)
                Button("添加记录") {
                    showingAddSheet = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                Spacer()
            } else {
                List {
                    ForEach(reports) { report in
                        let dict = parseReportJson(report.reportJson) ?? [:]
                        VStack(alignment: .leading, spacing: 4) {
                            Text("检查日期：\(report.checkDate)").font(.headline)
                            SkinPrickFieldsView(dict: dict)

                            if !report.remarks.isEmpty {
                                Text("备注：\(report.remarks)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                        .swipeActions {
                            Button(role: .destructive) {
                                table.deleteCheckReport(by: report.id)
                                loadReports()
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                            Button {
                                editingReport = report
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }.tint(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("皮肤点刺试验")
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
                category: "皮肤点刺",
                fields: CheckReportFields.skinPrickTestFields
            ) {
                loadReports()
                showingAddSheet = false
            }
        }
        .sheet(item: $editingReport) { report in
            EditReportView(
                report: report,
                category: "皮肤点刺",
                fields: CheckReportFields.skinPrickTestFields
            ) {
                loadReports()
            }
        }
        .onAppear {
            loadReports()
        }
    }

    func loadReports() {
        reports = table.queryReports(for: patientId, category: "皮肤点刺")
    }

    func parseReportJson(_ json: String) -> [String: String]? {
        if let data = json.data(using: .utf8) {
            return try? JSONDecoder().decode([String: String].self, from: data)
        }
        return nil
    }
}

struct SkinPrickFieldsView: View {
    let dict: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(CheckReportFields.skinPrickTestFields, id: \.self) { key in
                if let value = dict[key], !value.isEmpty {
                    Text("\(key)：\(value)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

