//
//  PatientListView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/28.
//
import SwiftUI

struct PatientListView: View {
    @State private var patients: [Patient] = []
    @State private var showingAddSheet = false

    let patientTable = PatientTable(db: DatabaseManager.shared.db)

    var body: some View {
        NavigationStack {
            List {
                ForEach(patients) { patient in
                    NavigationLink(destination: PatientDetailView(patient: patient,
                        onUpdate: loadPatients)) {
                        HStack(spacing:20){
                            // 状态颜色圆点
                            Circle()
                                .fill(color(for: patient.status))
                                .frame(width: 20, height: 20)
                            VStack(alignment: .leading) {
                                HStack(spacing:20){
                                    Text(patient.name).font(.headline)
                                    Text("性别：\(patient.gender)").font(.headline)
                                }
                                Text("生日：\(patient.birthdate)").font(.headline)
                            }
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deletePatient(patient)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }


            .navigationTitle("患者列表")
            .toolbar {
                Button(action: {
                    showingAddSheet = true
                }) {
                    Label("添加患者", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet, onDismiss: loadPatients) {
                AddPatientView(onSave: {
                    loadPatients()
                    showingAddSheet = false
                })
            }
            .onAppear(perform: loadPatients)
        }
    }
    
    func deletePatient(_ patient: Patient) {
        patientTable.deletePatient(by: patient.id)
        loadPatients()
    }

    func loadPatients() {
        patients = patientTable.queryAllPatients()
    }
    
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

#Preview {
    PatientListView()
}
