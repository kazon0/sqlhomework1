//
//  OtherFactorsFormView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//


import SwiftUI

struct OtherFactorsFormView: View {
    let patientId: Int32
    let table = OtherConfoundingFactorsTable(db: DatabaseManager.shared.db)

    @State private var dietHighProcessed = false
    @State private var dietTraditional = false
    @State private var vitaminD_daily400u = false
    @State private var vitaminD_durationYears = ""
    @State private var omega3_intakeMgPerDay = ""
    @State private var stressLevel_PSS10 = ""
    @State private var anxietyDepression_PHQ9_GAD7 = ""
    @State private var vaccine_planned = false
    @State private var antibiotic_useFrequency = ""
    @State private var breastfeeding = false
    @State private var breastfeedingMonths = ""
    @State private var delivery_natural = false
    @State private var delivery_csection = false
    @State private var petExposureAge = ""
    @State private var farmExposure = false
    @State private var farmExposureMonths = ""
    @State private var allergyAbsenceDaysPerYear = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("饮食")) {
                Toggle("高加工食品饮食", isOn: $dietHighProcessed)
                Toggle("传统饮食", isOn: $dietTraditional)
            }

            Section(header: Text("维生素D")) {
                Toggle("每日400单位维生素D", isOn: $vitaminD_daily400u)
                TextField("维生素D补充年数", text: $vitaminD_durationYears)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("营养摄入")) {
                TextField("Omega-3每日摄入毫克", text: $omega3_intakeMgPerDay)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("心理状态")) {
                TextField("压力水平(PSS10)", text: $stressLevel_PSS10)
                    .keyboardType(.numberPad)
                TextField("焦虑抑郁评分(PHQ9/GAD7)", text: $anxietyDepression_PHQ9_GAD7)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("疫苗和抗生素")) {
                Toggle("计划接种疫苗", isOn: $vaccine_planned)
                TextField("抗生素使用频率", text: $antibiotic_useFrequency)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("哺乳和分娩")) {
                Toggle("母乳喂养", isOn: $breastfeeding)
                TextField("哺乳月数", text: $breastfeedingMonths)
                    .keyboardType(.numberPad)
                Toggle("自然分娩", isOn: $delivery_natural)
                Toggle("剖腹产", isOn: $delivery_csection)
            }

            Section(header: Text("暴露史")) {
                TextField("接触宠物年龄（月）", text: $petExposureAge)
                    .keyboardType(.numberPad)
                Toggle("农场暴露", isOn: $farmExposure)
                TextField("农场暴露月数", text: $farmExposureMonths)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("过敏症状缺席天数")) {
                TextField("每年过敏缺席天数", text: $allergyAbsenceDaysPerYear)
                    .keyboardType(.numberPad)
            }

            Button("保存") {
                saveData()
            }
        }
        .navigationTitle("其他混杂因素")
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        }
        .onAppear(perform: loadData)
    }

    func loadData() {
        if let data = table.query(patientId: patientId) {
            dietHighProcessed = data.dietHighProcessed
            dietTraditional = data.dietTraditional
            vitaminD_daily400u = data.vitaminD_daily400u
            vitaminD_durationYears = "\(data.vitaminD_durationYears)"
            omega3_intakeMgPerDay = "\(data.omega3_intakeMgPerDay)"
            stressLevel_PSS10 = "\(data.stressLevel_PSS10)"
            anxietyDepression_PHQ9_GAD7 = "\(data.anxietyDepression_PHQ9_GAD7)"
            vaccine_planned = data.vaccine_planned
            antibiotic_useFrequency = "\(data.antibiotic_useFrequency)"
            breastfeeding = data.breastfeeding
            breastfeedingMonths = "\(data.breastfeedingMonths)"
            delivery_natural = data.delivery_natural
            delivery_csection = data.delivery_csection
            petExposureAge = "\(data.petExposureAge)"
            farmExposure = data.farmExposure
            farmExposureMonths = "\(data.farmExposureMonths)"
            allergyAbsenceDaysPerYear = "\(data.allergyAbsenceDaysPerYear)"
        }
    }

    func saveData() {
        // 转换字符串到Int，失败时默认0
        let vitaminDYears = Int(vitaminD_durationYears) ?? 0
        let omega3Mg = Int(omega3_intakeMgPerDay) ?? 0
        let stressLevel = Int(stressLevel_PSS10) ?? 0
        let anxietyLevel = Int(anxietyDepression_PHQ9_GAD7) ?? 0
        let antibioticFreq = Int(antibiotic_useFrequency) ?? 0
        let breastfeedingM = Int(breastfeedingMonths) ?? 0
        let petAge = Int(petExposureAge) ?? 0
        let farmMonths = Int(farmExposureMonths) ?? 0
        let allergyDays = Int(allergyAbsenceDaysPerYear) ?? 0

        let success = table.insertOrUpdate(
            patientId: patientId,
            dietHighProcessed: dietHighProcessed,
            dietTraditional: dietTraditional,
            vitaminD_daily400u: vitaminD_daily400u,
            vitaminD_durationYears: vitaminDYears,
            omega3_intakeMgPerDay: omega3Mg,
            stressLevel_PSS10: stressLevel,
            anxietyDepression_PHQ9_GAD7: anxietyLevel,
            vaccine_planned: vaccine_planned,
            antibiotic_useFrequency: antibioticFreq,
            breastfeeding: breastfeeding,
            breastfeedingMonths: breastfeedingM,
            delivery_natural: delivery_natural,
            delivery_csection: delivery_csection,
            petExposureAge: petAge,
            farmExposure: farmExposure,
            farmExposureMonths: farmMonths,
            allergyAbsenceDaysPerYear: allergyDays
        )
        alertMessage = success ? "保存成功" : "保存失败"
        showAlert = true
    }
}
