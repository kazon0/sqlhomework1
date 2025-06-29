//
//  Followup.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

struct Followup: Identifiable {
    let id: Int32
    let patientId: Int32
    let followupDate: String
    let symptomScore: Int32
    let drugReaction: String
    let doctorFeedback: String
}
