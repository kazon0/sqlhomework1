//
//  BioSampleListView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

struct BioSampleListView: View {
    let patientId: Int32
    let table = SamplesTable(db: DatabaseManager.shared.db)

    @State private var samples: [Sample] = []
    @State private var showingAddSheet = false
    @State private var editingSample: Sample? = nil
    @State private var showingEditSheet = false

    var body: some View {
        VStack {
            if samples.isEmpty {
                Spacer()
                Text("暂无样本记录").foregroundColor(.gray).italic()
                Button("添加样本") {
                    showingAddSheet = true
                }
                .padding()
                .background(Color.purple.gradient)
                .foregroundColor(.white)
                .cornerRadius(12)
                Spacer()
            } else {
                List {
                    ForEach(samples) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("样本类型：\(item.sampleType)").bold()
                            Text("采集日期：\(item.collectionDate)")
                            Text("储存方式：\(item.storageMethod)")
                            Text("样本编号：\(item.sampleCode)")
                        }
                        .padding(.vertical, 6)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                table.deleteSample(by: item.id)
                                refreshList()
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                editingSample = item
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
        .navigationTitle("样本管理")
        .toolbar {
            Button {
                showingAddSheet = true
            } label: {
                Label("添加", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddSampleView(patientId: patientId) {
                refreshList()
                showingAddSheet = false
            }
        }
        .sheet(item: $editingSample) { sample in
            EditSampleView(sample: sample) {
                refreshList()
                showingEditSheet = false
            }
        }
        .onAppear {
            refreshList()
        }
    }

    func refreshList() {
        samples = table.querySamples(for: patientId)
    }
}
