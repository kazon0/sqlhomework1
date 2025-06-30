//
//  ResidenceInfoFormView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//


import SwiftUI

struct ResidenceInfoFormView: View {
    let patientId: Int32
    let table = ResidenceInfoTable(db: DatabaseManager.shared.db)

    // 绑定属性
    @State private var houseType = ""
    @State private var buildingMaterial = ""
    @State private var ventilationFrequency = ""
    @State private var acUsageSeason = ""
    @State private var acFrequency = ""
    @State private var acTemperatureSetting = ""
    @State private var acMode = ""
    @State private var acFilterCleaningFrequency = ""
    @State private var heatingUsageFrequency = ""
    @State private var roomTemperatureRange = ""
    @State private var hasCarpet = false
    @State private var hasStuffedToys = false

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("居住环境")) {
                TextField("房屋类型", text: $houseType)
                TextField("建筑材料", text: $buildingMaterial)
                TextField("通风频率", text: $ventilationFrequency)
                TextField("空调使用季节", text: $acUsageSeason)
                TextField("空调使用频率", text: $acFrequency)
                TextField("空调温度设定", text: $acTemperatureSetting)
                TextField("空调模式", text: $acMode)
                TextField("空调滤网清洁频率", text: $acFilterCleaningFrequency)
                TextField("暖气使用频率", text: $heatingUsageFrequency)
                TextField("室温范围", text: $roomTemperatureRange)
                Toggle("有地毯", isOn: $hasCarpet)
                Toggle("有毛绒玩具", isOn: $hasStuffedToys)
            }

            Section {
                Button("保存") {
                    saveData()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("居住环境信息")
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        }
        .onAppear {
            loadData()
        }
    }

    func loadData() {
        if let data = table.query(patientId: patientId) {
            houseType = data.houseType
            buildingMaterial = data.buildingMaterial
            ventilationFrequency = data.ventilationFrequency
            acUsageSeason = data.acUsageSeason
            acFrequency = data.acFrequency
            acTemperatureSetting = data.acTemperatureSetting
            acMode = data.acMode
            acFilterCleaningFrequency = data.acFilterCleaningFrequency
            heatingUsageFrequency = data.heatingUsageFrequency
            roomTemperatureRange = data.roomTemperatureRange
            hasCarpet = data.hasCarpet
            hasStuffedToys = data.hasStuffedToys
        }
    }

    func saveData() {
        let result = table.insertOrUpdate(
            patientId: patientId,
            houseType: houseType,
            buildingMaterial: buildingMaterial,
            ventilationFrequency: ventilationFrequency,
            acUsageSeason: acUsageSeason,
            acFrequency: acFrequency,
            acTemperatureSetting: acTemperatureSetting,
            acMode: acMode,
            acFilterCleaningFrequency: acFilterCleaningFrequency,
            heatingUsageFrequency: heatingUsageFrequency,
            roomTemperatureRange: roomTemperatureRange,
            hasCarpet: hasCarpet,
            hasStuffedToys: hasStuffedToys
        )
        alertMessage = result ? "保存成功" : "保存失败"
        showAlert = true
    }
}

