//
//  FamilyHistoryFormView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/7/1.
//


import SwiftUI

struct FamilyHistoryFormView: View {
    let patientId: Int32
    let table = FamilyHistoryTable(db: DatabaseManager.shared.db)

    @State private var asthmaFirstDegree = false
    @State private var eczemaFirstDegree = false
    @State private var rhinitisFirstDegree = false
    @State private var foodAllergyFirstDegree = false
    @State private var relationFirstDegree = ""

    @State private var asthmaSecondDegree = false
    @State private var eczemaSecondDegree = false
    @State private var rhinitisSecondDegree = false
    @State private var foodAllergySecondDegree = false
    @State private var relationSecondDegree = ""

    @State private var sharedExposureSmoking = false

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("一级亲属过敏史")) {
                Toggle("哮喘", isOn: $asthmaFirstDegree)
                Toggle("湿疹", isOn: $eczemaFirstDegree)
                Toggle("鼻炎", isOn: $rhinitisFirstDegree)
                Toggle("食物过敏", isOn: $foodAllergyFirstDegree)
                TextField("关系描述", text: $relationFirstDegree)
            }

            Section(header: Text("二级亲属过敏史")) {
                Toggle("哮喘", isOn: $asthmaSecondDegree)
                Toggle("湿疹", isOn: $eczemaSecondDegree)
                Toggle("鼻炎", isOn: $rhinitisSecondDegree)
                Toggle("食物过敏", isOn: $foodAllergySecondDegree)
                TextField("关系描述", text: $relationSecondDegree)
            }

            Section {
                Toggle("共同暴露于吸烟环境", isOn: $sharedExposureSmoking)
            }

            Button("保存") {
                saveData()
            }
        }
        .navigationTitle("家族史")
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        }
        .onAppear(perform: loadData)
    }

    func loadData() {
        if let data = table.query(patientId: patientId) {
            asthmaFirstDegree = data.asthmaFirstDegree
            eczemaFirstDegree = data.eczemaFirstDegree
            rhinitisFirstDegree = data.rhinitisFirstDegree
            foodAllergyFirstDegree = data.foodAllergyFirstDegree
            relationFirstDegree = data.relationFirstDegree

            asthmaSecondDegree = data.asthmaSecondDegree
            eczemaSecondDegree = data.eczemaSecondDegree
            rhinitisSecondDegree = data.rhinitisSecondDegree
            foodAllergySecondDegree = data.foodAllergySecondDegree
            relationSecondDegree = data.relationSecondDegree

            sharedExposureSmoking = data.sharedExposureSmoking
        }
    }

    func saveData() {
        let success = table.insertOrUpdate(
            patientId: patientId,
            asthmaFirstDegree: asthmaFirstDegree,
            eczemaFirstDegree: eczemaFirstDegree,
            rhinitisFirstDegree: rhinitisFirstDegree,
            foodAllergyFirstDegree: foodAllergyFirstDegree,
            relationFirstDegree: relationFirstDegree,
            asthmaSecondDegree: asthmaSecondDegree,
            eczemaSecondDegree: eczemaSecondDegree,
            rhinitisSecondDegree: rhinitisSecondDegree,
            foodAllergySecondDegree: foodAllergySecondDegree,
            relationSecondDegree: relationSecondDegree,
            sharedExposureSmoking: sharedExposureSmoking
        )
        alertMessage = success ? "保存成功" : "保存失败"
        showAlert = true
    }
}
