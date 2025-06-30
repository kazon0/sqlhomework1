//
//  CheckReportFields.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import Foundation

struct CheckReportFields {
    static let bloodRoutineFields = [
        "白细胞计数", "中性粒细胞计数", "淋巴细胞计数", "嗜酸性粒细胞计数",
        "中性粒细胞百分比", "淋巴细胞百分比", "嗜酸性粒细胞百分比",
        "血红蛋白", "红细胞计数", "血小板", "C反应蛋白"
    ]

    static let igEFields = [
        "总IgE", "尘螨组合", "霉菌组合", "宠物毛屑组合",
        "常见食物组合", "坚果组合"
    ]

    static let allergenSingleFields = [
        "屋尘螨", "粉尘螨", "花粉", "杂草", "烟曲霉",
        "链格孢", "蟑螂", "猫皮屑", "狗毛屑",
        "鸡蛋白", "牛奶", "虾", "螃蟹", "大豆",
        "芝麻", "小麦", "坚果", "其它"
    ]

    static let skinPrickTestFields = [
        "屋尘螨", "粉尘螨"
    ]

    static let sputumEosinophilFields = [
        "痰嗜酸性粒细胞计数"
    ]

    static let lungFunctionFields = [
        "IC", "MEF50", "FEV1", "FVC", "MMEF75/25",
        "FEV1/FVC", "MEF25", "MEF75", "MVV",
        "FEV1/VCmax", "VCmax", "结论"
    ]

    static let bronchodilatorTestFields = ["支气管舒张试验结果"]
    static let bronchialProvocationTestFields = ["支气管激发试验结果"]


    static let tidalLungFunctionFields = [
        "WT/kg", "RRD", "Ti", "TeO", "Ti/Te",
        "TPTEFO", "VPTEFO", "TPTEF/TEO", "VPEF/VED",
        "PTEFO", "TEF50/TIF50", "TEF50", "TEF25", "TBF25-750"
    ]
}
