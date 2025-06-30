//
//  AllergenReportView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct AllergenReportListView: View {
    let patientId: Int32
    let table = CheckReportsTable(db: DatabaseManager.shared.db)
    
    @State private var reports: [CheckReport] = []
    @State private var showingAddSheet = false
    @State private var editingReport: CheckReport? = nil
    
    var body: some View {
        VStack {
            if reports.isEmpty {
                Spacer()
                Text("暂无过敏原记录").foregroundColor(.gray)
                Button("添加过敏原检查") {
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
                        VStack(alignment: .leading) {
                            Text("检查日期：\(report.checkDate)")
                                .font(.headline)
                            if let dict = parseReportJson(report.reportJson) {
                                ForEach(CheckReportFields.igEFields + CheckReportFields.allergenSingleFields, id: \.self) { key in
                                    if let item = dict[key] {
                                        // item 是 [String: String]，包括 value 和 conclusion
                                        let value = item["value"] ?? ""
                                        let conclusion = item["conclusion"] ?? ""
                                        Text("\(key)： \(value)    \(conclusion)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
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
        .navigationTitle("过敏原检查")
        .toolbar {
            Button {
                showingAddSheet = true
            } label: {
                Label("添加", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddAllergenReportView(patientId: patientId) {
                loadReports()
                showingAddSheet = false
            }
        }
        .sheet(item: $editingReport) { report in
            EditAllergenReportView(report: report) {
                loadReports()
            }
        }
        .onAppear {
            loadReports()
        }
    }
    
    func loadReports() {
        reports = table.queryReports(for: patientId, category: "过敏原")
    }
    
    func parseReportJson(_ json: String) -> [String: [String: String]]? {
        guard let data = json.data(using: .utf8) else {
            print("json 转 data 失败")
            return nil
        }
        do {
            let result = try JSONDecoder().decode([String: [String: String]].self, from: data)
            print("json 解析成功：\(result)")
            return result
        } catch {
            print("json 解析失败：\(error)")
            return nil
        }
    }

}
