//
//  EpidemiologyFormView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

struct EpidemiologyFormView: View {
    let patientId: Int32
    let table = EpidemiologyTable(db: DatabaseManager.shared.db)

    @State private var hasPets = false
    @State private var dustExposure = false
    @State private var familyHistory = false
    @State private var smoking = false

    @State private var hasLoaded = false
    @State private var showSuccessAlert = false

    var body: some View {
        Form {
            Section(header: Text("流行病学调查")) {
                Toggle("是否养宠物", isOn: $hasPets)
                Toggle("是否接触粉尘", isOn: $dustExposure)
                Toggle("是否有家族史", isOn: $familyHistory)
                Toggle("是否吸烟", isOn: $smoking)
            }

            Section {
                Button(action: saveData) {
                    Label("保存调查信息", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("流调信息")
        .onAppear {
            if !hasLoaded {
                loadData()
                hasLoaded = true
            }
        }
        .alert("保存成功", isPresented: $showSuccessAlert) {
            Button("确定", role: .cancel) { }
        }
    }

    func loadData() {
        if let record = table.queryEpidemiology(for: patientId) {
            hasPets = record.pets
            dustExposure = record.dustExposure
            familyHistory = record.familyHistory
            smoking = record.smoking
        }
    }

    func saveData() {
        table.insertEpidemiology(
            patientId: patientId,
            pets: hasPets,
            dustExposure: dustExposure,
            familyHistory: familyHistory,
            smoking: smoking
        )
        showSuccessAlert = true
    }
}

#Preview {
    NavigationStack {
        EpidemiologyFormView(patientId: 1)
    }
}
