//
//  Diagnosis.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

struct Diagnosis: Identifiable {
    let id: Int32
    let patientId: Int32
    let diseaseType: String
    let customName: String
    let visitDate: String
    let allergens: String
    let treatment: String
    let symptomJson: String
}

struct AsthmaSymptomData: Codable {
    var wheezing: Bool = false
    var coughing: Bool = false
    var chestTightness: Bool = false
    var triggers: [String] = []
}

struct RhinitisSymptomData: Codable {
    var sneezing: Bool = false
    var runnyNose: Bool = false
    var nasalCongestion: Bool = false
    var eyeItching: Bool = false
}

struct DermatitisSymptomData: Codable {
    var drySkin: Bool = false
    var eczemaHistory: Bool = false
    var fishScaleSkin: Bool = false
    var darkEyeCircle: Bool = false
    var skinInfection: Bool = false  
}

let diseaseTypes = ["哮喘", "过敏性鼻炎", "湿疹", "其他"]

// 主要治疗选项字典
let mainTreatmentOptions: [String: [String]] = [
    "哮喘": ["吸入性糖皮质激素", "长效B：受体激动剂", "白三烯受体拮抗剂", "茶碱", "短效B：受体激动剂"],
    "过敏性鼻炎": ["抗组胺药", "糖皮质激素", "白三烯受体拮抗剂", "肥大细胞膜稳定剂", "抗胆碱能药"],
    "湿疹": ["糖皮质激素", "钙调神经磷酸酶抑制剂"],
    "食物过敏": ["糖皮质激素", "抗组胺药"]
]

// 辅助治疗选项（固定）
let adjunctTreatmentOptions = ["过敏原特异性免疫治疗", "抗免疫球蛋白 E 抗体治疗"]


