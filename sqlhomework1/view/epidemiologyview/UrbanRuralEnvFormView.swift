//
//  UrbanRuralEnvFormView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//


import SwiftUI

struct UrbanRuralEnvFormView: View {
    let patientId: Int32
    let table = UrbanRuralEnvironmentTable(db: DatabaseManager.shared.db)

    @State private var cityPM25AnnualAverage = ""
    @State private var cityPM25SeasonalVariation = ""
    @State private var cityPollenMainTypes = ""
    @State private var cityPollenMonthlyDistribution = ""
    @State private var cityPollenPeakConcentration = ""
    @State private var cityOtherPollutants = ""
    @State private var cityMonitoringSiteType = ""

    @State private var ruralPM25BurningPeriod = ""
    @State private var ruralPM25AnnualAverage = ""
    @State private var ruralCropPollenTypes = ""
    @State private var biomassFuelIndoorPollution = false
    @State private var drinkingWaterSource = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("城市环境")) {
                TextField("城市PM2.5年均值", text: $cityPM25AnnualAverage)
                    .keyboardType(.decimalPad)
                TextField("城市PM2.5季节变化", text: $cityPM25SeasonalVariation)
                TextField("主要花粉类型", text: $cityPollenMainTypes)
                TextField("花粉月分布", text: $cityPollenMonthlyDistribution)
                TextField("花粉峰值浓度", text: $cityPollenPeakConcentration)
                    .keyboardType(.decimalPad)
                TextField("其他污染物", text: $cityOtherPollutants)
                TextField("监测点类型", text: $cityMonitoringSiteType)
            }

            Section(header: Text("农村环境")) {
                TextField("农村燃烧期PM2.5浓度", text: $ruralPM25BurningPeriod)
                    .keyboardType(.decimalPad)
                TextField("农村PM2.5年均值", text: $ruralPM25AnnualAverage)
                    .keyboardType(.decimalPad)
                TextField("农村作物花粉类型", text: $ruralCropPollenTypes)
                Toggle("使用生物质燃料导致室内污染", isOn: $biomassFuelIndoorPollution)
                TextField("饮用水来源", text: $drinkingWaterSource)
            }

            Button("保存") {
                saveData()
            }
        }
        .navigationTitle("城乡环境监测")
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        }
        .onAppear(perform: loadData)
    }

    func loadData() {
        if let data = table.query(patientId: patientId) {
            cityPM25AnnualAverage = String(format: "%.2f", data.cityPM25AnnualAverage)
            cityPM25SeasonalVariation = data.cityPM25SeasonalVariation
            cityPollenMainTypes = data.cityPollenMainTypes
            cityPollenMonthlyDistribution = data.cityPollenMonthlyDistribution
            cityPollenPeakConcentration = String(format: "%.2f", data.cityPollenPeakConcentration)
            cityOtherPollutants = data.cityOtherPollutants
            cityMonitoringSiteType = data.cityMonitoringSiteType

            ruralPM25BurningPeriod = String(format: "%.2f", data.ruralPM25BurningPeriod)
            ruralPM25AnnualAverage = String(format: "%.2f", data.ruralPM25AnnualAverage)
            ruralCropPollenTypes = data.ruralCropPollenTypes
            biomassFuelIndoorPollution = data.biomassFuelIndoorPollution
            drinkingWaterSource = data.drinkingWaterSource
        }
    }

    func saveData() {
        let result = table.insertOrUpdate(
            patientId: patientId,
            cityPM25AnnualAverage: Double(cityPM25AnnualAverage) ?? 0,
            cityPM25SeasonalVariation: cityPM25SeasonalVariation,
            cityPollenMainTypes: cityPollenMainTypes,
            cityPollenMonthlyDistribution: cityPollenMonthlyDistribution,
            cityPollenPeakConcentration: Double(cityPollenPeakConcentration) ?? 0,
            cityOtherPollutants: cityOtherPollutants,
            cityMonitoringSiteType: cityMonitoringSiteType,
            ruralPM25BurningPeriod: Double(ruralPM25BurningPeriod) ?? 0,
            ruralPM25AnnualAverage: Double(ruralPM25AnnualAverage) ?? 0,
            ruralCropPollenTypes: ruralCropPollenTypes,
            biomassFuelIndoorPollution: biomassFuelIndoorPollution,
            drinkingWaterSource: drinkingWaterSource
        )
        alertMessage = result ? "保存成功" : "保存失败"
        showAlert = true
    }
}
