//
//  Followup.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

import Foundation

struct Followup: Codable, Identifiable {
    let id: Int32
    let patientId: Int32
    var followupDate: String
    var symptomScore: Int32
    var symptomsJson: SymptomsInfo?
    var drugReactionJson: [DrugReaction]?
    var doctorFeedback: String
    var otherInfoJson: OtherInfo?

    struct SymptomsInfo: Codable {
        struct Symptom: Codable {
            var name: String
            var severity: String?
            var durationDays: Int?
        }
        struct Sign: Codable {
            var name: String
            var present: Bool?
            var value: String?
        }
        var symptoms: [Symptom]
        var signs: [Sign]
    }

    struct DrugReaction: Codable {
        var drugName: String
        var reactionDate: String
        var dosage: String
        var durationDays: Int
        var symptoms: [String]
        var severity: String
    }

    struct OtherInfo: Codable {
        struct AuxiliaryTreatment: Codable {
            var treatmentMethod: String    // 治疗方法名称
            var startDate: String          // 开始时间，格式 YYYY-MM-DD
            var endDate: String?           // 结束时间，格式 YYYY-MM-DD，可为空
            var notes: String?             // 注意事项
        }
        
        struct Expense: Codable {
            var category: String           // 费用类别，比如“药物费”、“检查费”等
            var amount: Double             // 费用金额
            var date: String               // 费用发生日期，格式 YYYY-MM-DD
        }
        
        var auxiliaryTreatments: [AuxiliaryTreatment]?
        var expenses: [Expense]?
    }

}
