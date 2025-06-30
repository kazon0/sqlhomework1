//
//  InsuranceInfoView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct InsuranceInfoView: View {
    let patientId: Int32
    let table = InsuranceTable(db: DatabaseManager.shared.db)

    @State private var insurances: [Insurance] = []
    @State private var showingAddSheet = false
    @State private var editingInsurance: Insurance? = nil
    @State private var showingEditSheet = false

    var body: some View {
        VStack {
            if insurances.isEmpty {
                Spacer()
                Text("暂无医保信息").foregroundColor(.gray).italic()
                Button("添加医保信息") {
                    showingAddSheet = true
                }
                .padding()
                .background(Color.blue.gradient)
                .foregroundColor(.white)
                .cornerRadius(12)
                Spacer()
            } else {
                List {
                    ForEach(insurances) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("医保类型：\(item.insuranceType)").bold()
                            Text("卡号：\(item.insuranceNumber)")
                            Text("报销范围：\(item.coverageScope)")
                            Text("有效期：\(item.validFrom) 至 \(item.validTo)")
                            if let remarks = item.remarks, !remarks.isEmpty {
                                Text("备注：\(remarks)").italic().foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                table.deleteInsurance(by: item.id)
                                refreshList()
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                editingInsurance = item
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
        .navigationTitle("医保信息")
        .toolbar {
            Button {
                showingAddSheet = true
            } label: {
                Label("添加", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddInsuranceView(patientId: patientId) {
                refreshList()
                showingAddSheet = false
            }
        }
        .sheet(item: $editingInsurance) { insurance in
            EditInsuranceView(insurance: insurance) {
                refreshList()
                showingEditSheet = false
            }
        }
        .onAppear {
            refreshList()
        }
    }

    func refreshList() {
        insurances = table.queryInsurance(for: patientId)
    }
}
