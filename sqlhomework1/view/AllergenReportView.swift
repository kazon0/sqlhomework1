//
//  AllergenReportView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct AllergenReportView: View {
    let patientId: Int32

    var body: some View {
        VStack {
            Text("过敏原检查")
                .font(.title2)
                .padding()
            Spacer()
            Text("这里将显示 IgE 和过敏原记录")
                .foregroundColor(.gray)
                .italic()
            Spacer()
        }
    }
}
