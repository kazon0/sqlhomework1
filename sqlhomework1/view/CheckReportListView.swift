//
//  CheckReportListView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//

import SwiftUI

struct CheckReportListView: View {
    let patientId: Int32
    @State private var selectedTab = "血常规"

    let tabs = ["血常规", "过敏原", "皮肤点刺", "肺功能","呼出气一氧化氮检测","电子鼻咽喉镜","听力检查","鼻阻力","影像学检查"]

    var body: some View {
        VStack(spacing: 0) { // 减少间距
            // 顶部标签栏
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tabs, id: \.self) { tab in
                        Text(tab)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 14)
                            .background(selectedTab == tab ? Color.accentColor : Color.gray.opacity(0.2))
                            .foregroundColor(selectedTab == tab ? .white : .primary)
                            .cornerRadius(16)
                            .onTapGesture {
                                selectedTab = tab
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(UIColor.systemGroupedBackground))
            }

            Divider()

            // 内容视图（贴顶显示）
            Group {
                switch selectedTab {
                case "血常规":
                    BloodRoutineView(patientId: patientId)
                case "过敏原":
                    AllergenReportView(patientId: patientId)
                case "皮肤点刺":
                    SkinPrickTestView(patientId: patientId)
                case "肺功能":
                    LungFunctionView(patientId: patientId)
                default:
                    Text("暂不支持").foregroundColor(.gray)
                }
            }
        }
        .navigationBarTitle("检查报告", displayMode: .inline)
    }
}

#Preview {
    CheckReportListView(patientId: 1)
}
