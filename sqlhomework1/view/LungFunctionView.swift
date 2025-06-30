//
//  CheckReportListView 2.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct LungFunctionView: View {
    let patientId: Int32

    var body: some View {
        VStack {
            Text("肺功能检查")
                .font(.title2)
                .padding()
            Spacer()
            Text("这里将显示肺功能测试结果")
                .foregroundColor(.gray)
                .italic()
            Spacer()
        }
    }
}
