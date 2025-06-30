//
//  Patient.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import SwiftUI

struct Patient : Identifiable {
    var id: Int32
    var visitDate: String
    var name: String
    var gender: String
    var birthDate: String
    var age: Int
    var address: String
    var height: Double
    var weight: Double
    var birthWeight: Double
    var lifestyle: String
    var phone: String
    var status: String
}
