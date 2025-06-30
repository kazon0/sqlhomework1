//
//  WorkStudyEnvFormView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//

import SwiftUI

struct WorkStudyEnvFormView: View {
    let patientId: Int32
    let table = StudyWorkEnvironmentTable(db: DatabaseManager.shared.db)

    @State private var location = "城市中心" // 学校/单位位置
    @State private var ventilation = "良好" // 通风情况
    @State private var pm25AnnualAverage = ""
    @State private var pollenPeakConcentration = ""
    @State private var pollenTypesSelection: [String: Bool] = [
        "桑科": false, "豚草": false, "樟树": false, "松科": false, "水稻花粉": false, "柏树": false
    ]
    @State private var formaldehydeLevel = ""
    @State private var dustMiteExposure = false
    @State private var fabricFurnitureUse = false

    @State private var showAlert = false
    @State private var alertMessage = ""

    let locationOptions = ["城市中心", "郊区", "农村"]
    let ventilationOptions = ["良好", "一般", "差"]

    var body: some View {
        Form {
            Section(header: Text("学校/单位位置")) {
                Picker("位置", selection: $location) {
                    ForEach(locationOptions, id: \.self) { Text($0) }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("通风情况")) {
                Picker("通风情况", selection: $ventilation) {
                    ForEach(ventilationOptions, id: \.self) { Text($0) }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("PM2.5 暴露水平 (年均值)")) {
                TextField("PM2.5 年均值", text: $pm25AnnualAverage)
                    .keyboardType(.decimalPad)
            }

            Section(header: Text("花粉暴露")) {
                TextField("季节性峰值浓度", text: $pollenPeakConcentration)
                    .keyboardType(.decimalPad)

                VStack(alignment: .leading) {
                    Text("花粉种类（可多选）")
                    ForEach(pollenTypesSelection.keys.sorted(), id: \.self) { key in
                        Toggle(key, isOn: Binding(get: {
                            pollenTypesSelection[key] ?? false
                        }, set: {
                            pollenTypesSelection[key] = $0
                        }))
                    }
                }
            }

            Section(header: Text("甲醛检测值")) {
                TextField("甲醛检测值", text: $formaldehydeLevel)
                    .keyboardType(.decimalPad)
            }

            Section(header: Text("尘螨暴露")) {
                Toggle("地毯", isOn: $dustMiteExposure)
                Toggle("布艺家具使用", isOn: $fabricFurnitureUse)
            }

            Button("保存") {
                saveData()
            }
        }
        .navigationTitle("学习/工作环境")
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        }
        .onAppear(perform: loadData)
    }

    func loadData() {
        if let data = table.query(patientId: patientId) {
            location = data.location
            ventilation = data.ventilation
            pm25AnnualAverage = String(format: "%.2f", data.pm25AnnualAverage)
            pollenPeakConcentration = String(format: "%.2f", data.pollenPeakConcentration)
            formaldehydeLevel = String(format: "%.2f", data.formaldehydeLevel)
            dustMiteExposure = data.dustMiteExposure
            fabricFurnitureUse = data.fabricFurnitureUse
            
            // 恢复花粉种类
            let types = data.pollenTypes.split(separator: ",").map { String($0) }
            for key in pollenTypesSelection.keys {
                pollenTypesSelection[key] = types.contains(key)
            }
        }
    }

    func saveData() {
        guard
            let pm25 = Double(pm25AnnualAverage),
            let pollenPeak = Double(pollenPeakConcentration),
            let formaldehyde = Double(formaldehydeLevel)
        else {
            alertMessage = "请输入有效的数字"
            showAlert = true
            return
        }

        let selectedPollen = pollenTypesSelection.filter { $0.value }.map { $0.key }.joined(separator: ",")

        let result = table.insertOrUpdate(
            patientId: patientId,
            location: location,
            ventilation: ventilation,
            pm25AnnualAverage: pm25,
            pollenPeakConcentration: pollenPeak,
            pollenTypes: selectedPollen,
            formaldehydeLevel: formaldehyde,
            dustMiteExposure: dustMiteExposure,
            fabricFurnitureUse: fabricFurnitureUse
        )
        alertMessage = result ? "保存成功" : "保存失败"
        showAlert = true
    }
}
