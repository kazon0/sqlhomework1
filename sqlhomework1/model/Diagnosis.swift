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
    let diagnosis: String
    let visitDate: String
    let allergens: String
    let treatment: String
}
