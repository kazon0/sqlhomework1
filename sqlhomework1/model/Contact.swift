//
//  Contact.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct Contact: Identifiable {
    let id: Int32
    let patientId: Int32
    var name: String
    var relation: String
    var phone: String
    var address: String
    var email: String
    var remarks: String
}
