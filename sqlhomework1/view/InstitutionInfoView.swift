//
//  InstitutionInfoView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct InstitutionInfoView: View {
    let patientId: Int32

    var body: some View {
        VStack {
            Text("医疗服务机构界面")
                .font(.title)
                .padding()

            Text("患者 ID: \(patientId)")
        }
        .navigationTitle("医疗机构")
    }
}
