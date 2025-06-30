//
//  CheckReport.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct CheckReport: Identifiable {
    let id: Int32
    let patientId: Int32
    let category: String       // 检查类别，如“血常规”
    let subType: String        // 子类型，如“总IgE”
    let checkDate: String      // yyyy-MM-dd
    let reportJson: String     // JSON 格式的具体字段和值
    let remarks: String
}
