//
//  PatientDetailView 2.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import SwiftUI

struct DiagnosisListView: View {
    let patientId: Int32
    let table = DiagnosisTable(db: DatabaseManager.shared.db)

    @State private var diagnoses: [Diagnosis] = []
    @State private var showingAddSheet = false
    
    @State private var editingDiagnosis: Diagnosis? = nil
    @State private var showingEditSheet = false

    var body: some View {
        VStack {
            
            if diagnoses.isEmpty {
                Spacer()
                Text("暂无诊断信息")
                    .foregroundColor(.gray)
                    .italic()
                Button(action:{
                    showingAddSheet = true
                }){
                    Text("添加记录")
                }
                .padding()
                .background(Color.blue.gradient)
                .foregroundColor(.white)
                .cornerRadius(12)
                Spacer()
            } else {
                List {
                    ForEach(diagnoses) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("诊断：\(item.diagnosis)").bold()
                            Text("时间：\(item.visitDate)")
                            Text("过敏原：\(item.allergens)")
                            Text("治疗方案：\(item.treatment)")
                        }
                        .padding(.vertical, 6)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteDiagnosis(item)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                editDiagnosis(item)
                            } label: {
                                Label("修改", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("诊断记录")
        .toolbar {
            Button(action: {
                showingAddSheet = true
            }) {
                Label("添加诊断", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddDiagnosisView(patientId: patientId) {
                // 新增完成后刷新列表
                diagnoses = table.queryDiagnoses(for: patientId)
                showingAddSheet = false
            }
        }
        .sheet(item: $editingDiagnosis) { editing in
            EditDiagnosisView(diagnosis: editing) {
                diagnoses = table.queryDiagnoses(for: patientId)
                editingDiagnosis = nil // 清除后自动关闭 sheet
            }
        }
        .onAppear {
            diagnoses = table.queryDiagnoses(for: patientId)
        }
    }
    
    func editDiagnosis(_ item: Diagnosis) {
        editingDiagnosis = item
        showingEditSheet = true
    }
    
    func deleteDiagnosis(_ item: Diagnosis) {
        table.deleteDiagnosis(by: item.id)
        diagnoses = table.queryDiagnoses(for: patientId)
    }

}

struct DiagnosisListView_PreviewWrapper: View {
    @State private var fakeDiagnoses: [Diagnosis] = []
    var body: some View {
        DiagnosisListView(patientId: 1)
    }
}

struct DiagnosisListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiagnosisListView_PreviewWrapper()
        }
    }
}
