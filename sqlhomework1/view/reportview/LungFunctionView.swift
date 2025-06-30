//
//  CheckReportListView 2.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct LungFunctionView: View {
    let patientId: Int32
    let table = CheckReportsTable(db: DatabaseManager.shared.db)

    @State private var reports: [CheckReport] = []
    @State private var showingAddSheet = false
    @State private var editingReport: CheckReport? = nil

    var body: some View {
        VStack {
            if reports.isEmpty {
                Spacer()
                Text("暂无肺功能检查记录")
                    .foregroundColor(.gray)
                Button("添加肺功能检查") {
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
                            Text("检查日期：\(report.checkDate)")
                                .font(.headline)
                            
                            let displayFields = fieldsForSubType(report.subType)
                            
                            ForEach(displayFields, id: \.self) { key in
                                if let value = dict[key], !value.isEmpty {
                                    Text("\(key)：\(value)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }

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
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("肺功能检查")
        .toolbar {
            Button {
                showingAddSheet = true
            } label: {
                Label("添加", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddLungFunctionReportView(patientId: patientId) {
                loadReports()
                showingAddSheet = false
            }
        }
        .sheet(item: $editingReport) { report in
            EditLungFunctionReportView(report: report) {
                loadReports()
                editingReport = nil
            }
        }
        .onAppear {
            loadReports()
        }
    }

    func fieldsForSubType(_ subType: String) -> [String] {
        switch subType {
        case "支气管舒张试验":
            return CheckReportFields.bronchodilatorTestFields
        case "支气管激发试验":
            return CheckReportFields.bronchialProvocationTestFields
        case "潮气肺功能检查":
            return CheckReportFields.tidalLungFunctionFields
        default:
            return CheckReportFields.lungFunctionFields
        }
    }

    func loadReports() {
        reports = table.queryReports(for: patientId,category: "肺功能")
            .filter { $0.category == "肺功能" }
    }

    func parseReportJson(_ json: String) -> [String: String]? {
        if let data = json.data(using: .utf8) {
            return try? JSONDecoder().decode([String: String].self, from: data)
        }
        return nil
    }
}
