//
//  Insurance.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct Insurance: Identifiable {
    var id: Int32 = 0
    var patientId: Int32 = 0
    var insuranceType: String = ""
    var insuranceNumber: String = ""
    var coverageScope: String = ""
    var validFrom: String = ""
    var validTo: String = ""
    var remarks: String? = nil
}
