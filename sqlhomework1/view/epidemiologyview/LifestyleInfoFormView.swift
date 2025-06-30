//
//  LifestyleInfoFormView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//


import SwiftUI

struct LifestyleInfoFormView: View {
    let patientId: Int32
    let table = AllergenLifestyleTable(db: DatabaseManager.shared.db)

    // 过敏原浓度及相关字段
    @State private var pm25Concentration: String = ""
    @State private var pollenTypes: String = ""
    @State private var formaldehydeConcentration: String = ""
    @State private var formaldehydeTestDate = Date()
    @State private var dustMiteConcentration: String = ""
    @State private var otherAllergens: String = ""

    // 运动相关
    @State private var exerciseFrequencyPerWeek: String = ""
    @State private var exerciseDurationMinutes: String = ""
    @State private var exerciseIntensity: String = "中等"
    @State private var swimming: Bool = false

    // 睡眠相关
    @State private var sleepHoursPerDay: String = ""
    @State private var hasInsomnia: Bool = false
    @State private var circadianRhythmDisorder: Bool = false

    // 吸烟、清洁
    @State private var smokingStatus: String = "非吸烟者"
    @State private var cleaningFrequency: String = "每周一次"

    // 宠物相关
    @State private var hasCat: Bool = false
    @State private var hasDog: Bool = false
    @State private var hasBird: Bool = false
    @State private var otherPets: String = ""
    @State private var petCount: String = ""

    // 同住吸烟者
    @State private var smokerCohabitant: Bool = false

    // 其他
    @State private var cookingFuelType: String = "天然气"
    @State private var airPurifierUsed: Bool = false
    @State private var vacuumCleanerUsed: Bool = false
    @State private var allergenAvoidanceEffectiveness: String = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    var exerciseIntensityOptions = ["低", "中等", "高"]
    var smokingStatusOptions = ["非吸烟者", "偶尔吸烟", "每日吸烟"]
    var cleaningFrequencyOptions = ["每日", "每周一次", "每月一次", "几乎不清洁"]
    var cookingFuelTypeOptions = ["天然气", "液化气", "煤炭", "电", "其他"]

    var body: some View {
        Form {
            Section("环境过敏原") {
                TextField("PM2.5浓度 (µg/m³)", text: $pm25Concentration)
                    .keyboardType(.decimalPad)
                TextField("花粉类型", text: $pollenTypes)
                TextField("甲醛浓度 (mg/m³)", text: $formaldehydeConcentration)
                    .keyboardType(.decimalPad)
                DatePicker("甲醛测试日期", selection: $formaldehydeTestDate, displayedComponents: .date)
                TextField("尘螨浓度", text: $dustMiteConcentration)
                    .keyboardType(.decimalPad)
                TextField("其他过敏原", text: $otherAllergens)
            }

            Section("运动情况") {
                TextField("每周运动次数", text: $exerciseFrequencyPerWeek)
                    .keyboardType(.numberPad)
                TextField("每次运动分钟数", text: $exerciseDurationMinutes)
                    .keyboardType(.numberPad)
                Picker("运动强度", selection: $exerciseIntensity) {
                    ForEach(exerciseIntensityOptions, id: \.self) { Text($0) }
                }
                Toggle("是否游泳", isOn: $swimming)
            }

            Section("睡眠情况") {
                TextField("每日睡眠小时数", text: $sleepHoursPerDay)
                    .keyboardType(.decimalPad)
                Toggle("有失眠", isOn: $hasInsomnia)
                Toggle("昼夜节律紊乱", isOn: $circadianRhythmDisorder)
            }

            Section("生活习惯") {
                Picker("吸烟状态", selection: $smokingStatus) {
                    ForEach(smokingStatusOptions, id: \.self) { Text($0) }
                }
                Picker("清洁频率", selection: $cleaningFrequency) {
                    ForEach(cleaningFrequencyOptions, id: \.self) { Text($0) }
                }
            }

            Section("宠物") {
                Toggle("有猫", isOn: $hasCat)
                Toggle("有狗", isOn: $hasDog)
                Toggle("有鸟", isOn: $hasBird)
                TextField("其他宠物", text: $otherPets)
                TextField("宠物数量", text: $petCount)
                    .keyboardType(.numberPad)
            }

            Section("同住吸烟者") {
                Toggle("有吸烟者同住", isOn: $smokerCohabitant)
            }

            Section("居家设施") {
                Picker("烹饪燃料类型", selection: $cookingFuelType) {
                    ForEach(cookingFuelTypeOptions, id: \.self) { Text($0) }
                }
                Toggle("使用空气净化器", isOn: $airPurifierUsed)
                Toggle("使用吸尘器", isOn: $vacuumCleanerUsed)
            }

            Section("过敏原避免效果") {
                TextField("效果描述", text: $allergenAvoidanceEffectiveness)
            }

            Section {
                Button("保存") {
                    saveData()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("生活状态")
        .onAppear(perform: loadData)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        }
    }

    func loadData() {
        if let data = table.query(patientId: patientId) {
            pm25Concentration = String(format: "%.2f", data.pm25Concentration)
            pollenTypes = data.pollenTypes
            formaldehydeConcentration = String(format: "%.2f", data.formaldehydeConcentration)
            if let date = parseDate(from: data.formaldehydeTestDate) {
                formaldehydeTestDate = date
            }
            dustMiteConcentration = String(format: "%.2f", data.dustMiteConcentration)
            otherAllergens = data.otherAllergens

            exerciseFrequencyPerWeek = String(data.exerciseFrequencyPerWeek)
            exerciseDurationMinutes = String(data.exerciseDurationMinutes)
            exerciseIntensity = data.exerciseIntensity
            swimming = data.swimming

            sleepHoursPerDay = String(format: "%.2f", data.sleepHoursPerDay)
            hasInsomnia = data.hasInsomnia
            circadianRhythmDisorder = data.circadianRhythmDisorder

            smokingStatus = data.smokingStatus
            cleaningFrequency = data.cleaningFrequency

            hasCat = data.hasCat
            hasDog = data.hasDog
            hasBird = data.hasBird
            otherPets = data.otherPets
            petCount = String(data.petCount)

            smokerCohabitant = data.smokerCohabitant

            cookingFuelType = data.cookingFuelType
            airPurifierUsed = data.airPurifierUsed
            vacuumCleanerUsed = data.vacuumCleanerUsed

            allergenAvoidanceEffectiveness = data.allergenAvoidanceEffectiveness
        }
    }

    func saveData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let testDateStr = formatter.string(from: formaldehydeTestDate)

        let result = table.insertOrUpdate(
            patientId: patientId,
            pm25Concentration: Double(pm25Concentration) ?? 0,
            pollenTypes: pollenTypes,
            formaldehydeConcentration: Double(formaldehydeConcentration) ?? 0,
            formaldehydeTestDate: testDateStr,
            dustMiteConcentration: Double(dustMiteConcentration) ?? 0,
            otherAllergens: otherAllergens,
            exerciseFrequencyPerWeek: Int(exerciseFrequencyPerWeek) ?? 0,
            exerciseDurationMinutes: Int(exerciseDurationMinutes) ?? 0,
            exerciseIntensity: exerciseIntensity,
            swimming: swimming,
            sleepHoursPerDay: Double(sleepHoursPerDay) ?? 0,
            hasInsomnia: hasInsomnia,
            circadianRhythmDisorder: circadianRhythmDisorder,
            smokingStatus: smokingStatus,
            cleaningFrequency: cleaningFrequency,
            hasCat: hasCat,
            hasDog: hasDog,
            hasBird: hasBird,
            otherPets: otherPets,
            petCount: Int(petCount) ?? 0,
            smokerCohabitant: smokerCohabitant,
            cookingFuelType: cookingFuelType,
            airPurifierUsed: airPurifierUsed,
            vacuumCleanerUsed: vacuumCleanerUsed,
            allergenAvoidanceEffectiveness: allergenAvoidanceEffectiveness
        )

        alertMessage = result ? "保存成功" : "保存失败"
        showAlert = true
    }

    func parseDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}
