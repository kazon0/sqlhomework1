//
//  PatientCenterView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct PatientCenterView: View {
    let patient: Patient

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 基本信息卡片
                Text("详细信息栏")
                    .font(.title2)
                    .padding(.trailing,250)
                VStack(alignment: .leading, spacing: 12) {
                    PatientInfoCard(patient: patient)
                }
                .padding()
                .background(Color(#colorLiteral(red: 0.949019134, green: 0.9490200877, blue: 0.9705253243, alpha: 1)))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.horizontal)

                // 模块入口（医保、联系人、机构）
                VStack(spacing: 12) {
                    NavigationLink(destination: InsuranceInfoView(patientId: patient.id)) {
                        ModuleCard(icon: "cross.case.fill", title: "医保信息", color: .blue)
                    }
                    NavigationLink(destination: ContactListView(patientId: patient.id)) {
                        ModuleCard(icon: "person.2.fill", title: "联系人信息", color: .orange)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("患者中心")
    }
}

struct PatientInfoCard: View {
    let patient: Patient

    let columns = [
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
            InfoItem(icon: "calendar", label: "就诊日期", value: patient.visitDate)
            Divider()
            InfoItem(icon: "ruler", label: "身高", value: String(format: "%.2f", patient.height) + " cm")
            Divider()
            InfoItem(icon: "scalemass", label: "体重", value: String(format: "%.2f", patient.weight) + " kg")
            Divider()
            InfoItem(icon: "figure.walk.circle", label: "出生体重", value: String(format: "%.2f", patient.birthWeight) + " kg")
            Divider()
            InfoItem(icon: "house", label: "地址", value: patient.address)
        }
        .padding()
        .frame(maxWidth: .infinity)

    }
}

struct InfoItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
                Text(label)
                    .font(.callout)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.callout)
                    .foregroundColor(.primary)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(x:-20)
    }
}


#Preview {
    PatientCenterView(patient: Patient(
        id: 1,
        visitDate: "2025-06-28",
        name: "张三",
        gender: "男",
        birthDate: "1990-01-01",
        age: 35,
        address: "北京市朝阳区建国路",
        height: 175.5,
        weight: 68.2,
        birthWeight: 3.2,
        lifestyle: "不吸烟，偶尔锻炼",
        phone: "13800138000",
        status: "在诊中"
    ))
}

