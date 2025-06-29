//
//  Epidemiology.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import Foundation

struct Epidemiology: Identifiable {
    var id: Int32 { patientId }
    let patientId: Int32
    let pets: Bool
    let dustExposure: Bool
    let familyHistory: Bool
    let smoking: Bool
}
