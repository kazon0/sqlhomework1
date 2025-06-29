//
//  EditDiagnosisView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/29.
//


import SwiftUI

struct EditDiagnosisView: View {
    @Environment(\.dismiss) var dismiss

    @State var diagnosisText: String
    @State var visitDate: String
    @State var allergens: String
    @State var treatment: String
    
    @State private var visitdateDate: Date

    let diagnosisId: Int32
    let onSave: () -> Void

    let table = DiagnosisTable(db: DatabaseManager.shared.db)

    init(diagnosis: Diagnosis, onSave: @escaping () -> Void) {
        _diagnosisText = State(initialValue: diagnosis.diagnosis)
        _visitDate = State(initialValue: diagnosis.visitDate)
        _allergens = State(initialValue: diagnosis.allergens)
        _treatment = State(initialValue: diagnosis.treatment)
        self.diagnosisId = diagnosis.id
        self.onSave = onSave
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: diagnosis.visitDate) {
            _visitdateDate = State(initialValue: date)
        } else {
            _visitdateDate = State(initialValue: Date())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("诊断", text: $diagnosisText)
                DatePicker("就诊时间", selection: $visitdateDate, displayedComponents: .date)
                TextField("过敏原", text: $allergens)
                TextField("治疗方案", text: $treatment)
            }
            .navigationTitle("编辑诊断记录")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        table.updateDiagnosis(id: diagnosisId,
                                              diagnosis: diagnosisText,
                                              visitDate: visitDate,
                                              allergens: allergens,
                                              treatment: treatment)
                        onSave()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}
