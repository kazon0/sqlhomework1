//
//  PatientDetailView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//


import SwiftUI

struct PatientDetailView: View {
    let patient: Patient
    let onUpdate: () -> Void
    @State private var showingEdit = false
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 卡片容器
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(patient.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action:{
                            showingEdit = true
                        }){
                            Image(systemName: "pencil")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(width: 20)
                        }
                    }
                    .sheet(isPresented: $showingEdit) {
                        EditPatientView(
                            name: patient.name,
                            gender: patient.gender,
                            birthdate: patient.birthdate,
                            phone: patient.phone,
                            status: patient.status,
                            patientId: patient.id,
                            onSave: {
                                showingEdit = false
                                onUpdate()
                            }
                        )
                    }
                    HStack {
                        Label(patient.gender, systemImage: "person.fill")
                        Spacer()
                        Label(patient.birthdate, systemImage: "calendar")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Divider()

                    HStack {
                        Label(patient.phone, systemImage: "phone.fill")
                        Spacer()
                        Label(patient.status, systemImage: "heart.fill")
                            .foregroundColor(color(for: patient.status))
                    }
                    .font(.headline)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)

                Spacer()
                
                HStack{
                    Text("就诊相关信息")
                        .font(.title)
                        .bold()
                        .padding(.trailing,180)
                }
                
                Section{
                    VStack(spacing: 12) {
                        NavigationLink(destination: DiagnosisListView(patientId: patient.id)) {
                            ModuleCard(icon: "stethoscope", title: "诊断记录", color: .blue)
                        }

                        NavigationLink(destination: FollowUpListView(patientId: patient.id)) {
                            ModuleCard(icon: "arrow.triangle.2.circlepath", title: "随访记录", color: .orange)
                        }

                        NavigationLink(destination: EpidemiologyFormView(patientId: patient.id)) {
                            ModuleCard(icon: "doc.text.magnifyingglass", title: "流调信息", color: .green)
                        }

                        NavigationLink(destination: BioSampleListView(patientId: patient.id)) {
                            ModuleCard(icon: "flask", title: "生物样本", color: .purple)
                        }
                    }
                    .padding(.vertical, 6)
                }

            }
            .padding()
        }
    }

    // 状态颜色匹配函数
    func color(for status: String) -> Color {
        switch status {
        case "在诊中":
            return .blue
        case "观察中":
            return .orange
        case "痊愈":
            return .green
        case "复发":
            return .red
        default:
            return .gray
        }
    }
}

struct ModuleCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding(10)
                .background(color)
                .clipShape(Circle())

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}



struct PatientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailView(
            patient: Patient(
                id: 1,
                name: "张三",
                gender: "男",
                birthdate: "1990-01-01",
                phone: "13800138000",
                status: "在诊中"
            ),
            onUpdate: {} 
        )
    }
}


