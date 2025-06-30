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

    @State private var residenceType = ""
    @State private var moldExposure = false
    @State private var secondHandSmoke = false
    @State private var ventilation = false
    @State private var humidity = ""

    @State private var hasLoaded = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("基本流调信息")) {
                Toggle("是否养宠物", isOn: $hasPets)
                Toggle("是否接触粉尘", isOn: $dustExposure)
                Toggle("是否有家族史", isOn: $familyHistory)
                Toggle("是否吸烟", isOn: $smoking)
            }

            Section(header: Text("居住与环境")) {
                TextField("居住类型（如城市/农村）", text: $residenceType)
                Toggle("是否暴露于霉菌", isOn: $moldExposure)
                Toggle("是否接触二手烟", isOn: $secondHandSmoke)
                Toggle("是否通风良好", isOn: $ventilation)
                TextField("居住湿度情况", text: $humidity)
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
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        }
    }

    func loadData() {
        if let record = table.queryEpidemiology(for: patientId) {
            hasPets = record.pets
            dustExposure = record.dustExposure
            familyHistory = record.familyHistory
            smoking = record.smoking
            residenceType = record.residenceType
            moldExposure = record.moldExposure
            secondHandSmoke = record.secondHandSmoke
            ventilation = record.ventilation
            humidity = record.humidity
        }
    }

    func saveData() {
        let result = table.insertEpidemiology(
            patientId: patientId,
            pets: hasPets,
            dustExposure: dustExposure,
            familyHistory: familyHistory,
            smoking: smoking,
            residenceType: residenceType,
            moldExposure: moldExposure,
            secondHandSmoke: secondHandSmoke,
            ventilation: ventilation,
            humidity: humidity
        )
        if result.success {
            alertMessage = "保存成功"
        } else {
            alertMessage = "保存失败：\(result.errorMessage ?? "未知错误")"
        }
        showAlert = true
    }
}

#Preview {
    NavigationStack {
        EpidemiologyFormView(patientId: 1)
    }
}
