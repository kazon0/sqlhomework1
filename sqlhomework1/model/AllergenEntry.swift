//
//  AllergenEntry.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct AllergenEntry: Identifiable {
    let id = UUID()
    var name: String
    var value: String = ""
    var conclusion: String = "阴性"
    var selected: Bool = false
}
