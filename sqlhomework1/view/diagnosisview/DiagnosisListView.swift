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
                        VStack(alignment: .leading, spacing: 6) {
                            Text("疾病类型：\(item.diseaseType == "其他" ? item.customName : item.diseaseType)")
                                .bold()
                            Text("就诊日期：\(item.visitDate)")
                                .font(.headline)
                            Text("治疗方案：\(item.treatment)")
                                .font(.headline)
                            HStack {
                                Text("症状详情：")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text(symptomDescription(for: item))
                                    .font(.headline)
    
                            }
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
                diagnoses = table.queryDiagnoses(for: patientId)
                showingAddSheet = false
            }
        }
        .sheet(item: $editingDiagnosis) { editing in
            EditDiagnosisView(diagnosis: editing) {
                diagnoses = table.queryDiagnoses(for: patientId)
                editingDiagnosis = nil
            }
        }
        .onAppear {
            diagnoses = table.queryDiagnoses(for: patientId)
        }
    }
    
    func editDiagnosis(_ item: Diagnosis) {
        editingDiagnosis = item
    }
    
    func deleteDiagnosis(_ item: Diagnosis) {
        table.deleteDiagnosis(by: item.id)
        diagnoses = table.queryDiagnoses(for: patientId)
    }
    
    func symptomDescription(for diagnosis: Diagnosis) -> String {
        let jsonData = diagnosis.symptomJson.data(using: .utf8) ?? Data()
        let diseaseType = diagnosis.diseaseType
        
        switch diseaseType {
        case "哮喘":
            if let asthma = try? JSONDecoder().decode(AsthmaSymptomData.self, from: jsonData) {
                var parts = [String]()
                if asthma.wheezing { parts.append("喘息") }
                if asthma.coughing { parts.append("咳嗽") }
                if asthma.chestTightness { parts.append("胸闷") }
                if !asthma.triggers.isEmpty { parts.append("诱因：\(asthma.triggers.joined(separator: ", "))") }
                return parts.isEmpty ? "无明显症状" : parts.joined(separator: "，")
            }
        case "过敏性鼻炎":
            if let rhinitis = try? JSONDecoder().decode(RhinitisSymptomData.self, from: jsonData) {
                var parts = [String]()
                if rhinitis.sneezing { parts.append("阵发性喷嚏") }
                if rhinitis.runnyNose { parts.append("流清水鼻涕") }
                if rhinitis.nasalCongestion { parts.append("鼻塞") }
                if rhinitis.eyeItching { parts.append("眼痒") }
                return parts.isEmpty ? "无明显症状" : parts.joined(separator: "，")
            }
        case "湿疹":
            if let dermatitis = try? JSONDecoder().decode(DermatitisSymptomData.self, from: jsonData) {
                var parts = [String]()
                if dermatitis.drySkin { parts.append("皮肤干燥") }
                if dermatitis.eczemaHistory { parts.append("复发性瘙痒性皮疹") }
                if dermatitis.fishScaleSkin { parts.append("鱼鳞皮肤") }
                if dermatitis.darkEyeCircle { parts.append("黑眼圈") }
                return parts.isEmpty ? "无明显症状" : parts.joined(separator: "，")
            }
        case "其他":
            return diagnosis.symptomJson.isEmpty ? "无症状描述" : diagnosis.symptomJson
        default:
            return "无症状信息"
        }
        return "症状解析失败"
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
