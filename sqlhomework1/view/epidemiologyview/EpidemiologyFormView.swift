//
//  EpidemiologyFormView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//

import SwiftUI

struct EpidemiologyMainEntryView: View {
    let patientId: Int32

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                NavigationLink(destination: EpidemiologyBasicInfoView(patientId: patientId)) {
                    ModuleCard(icon: "person.fill", title: "患儿基本信息", color: .blue)
                }

                NavigationLink(destination: ResidenceInfoFormView(patientId: patientId)) {
                    ModuleCard(icon: "house.fill", title: "居住环境信息", color: .orange)
                }

                NavigationLink(destination: LifestyleInfoFormView(patientId: patientId)) {
                    ModuleCard(icon: "heart.text.square", title: "生活状态", color: .pink)
                }

                NavigationLink(destination: WorkStudyEnvFormView(patientId: patientId)) {
                    ModuleCard(icon: "book.closed", title: "学习/工作环境", color: .indigo)
                }

                NavigationLink(destination: UrbanRuralEnvFormView(patientId: patientId)) {
                    ModuleCard(icon: "leaf.fill", title: "城乡环境监测", color: .green)
                }

                NavigationLink(destination: FamilyHistoryFormView(patientId: patientId)) {
                    ModuleCard(icon: "person.3.fill", title: "家族史", color: .purple)
                }

                NavigationLink(destination: OtherFactorsFormView(patientId: patientId)) {
                    ModuleCard(icon: "questionmark.circle", title: "其他混杂因素", color: .gray)
                }
            }
            .padding()
        }
        .navigationTitle("流调信息")
    }
}
