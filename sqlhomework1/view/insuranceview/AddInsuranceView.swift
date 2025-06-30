//
//  AddInsuranceView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct AddInsuranceView: View {
    let patientId: Int32
    let onSave: () -> Void
    let table = InsuranceTable(db: DatabaseManager.shared.db)

    @Environment(\.dismiss) var dismiss

    @State private var insuranceType = ""
    @State private var insuranceNumber = ""
    @State private var coverageScope = ""
    @State private var validFrom = ""
    @State private var validTo = ""
    @State private var remarks = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("医保信息")) {
                    TextField("医保类型", text: $insuranceType)
                    TextField("医保卡号", text: $insuranceNumber)
                    TextField("报销范围", text: $coverageScope)
                    TextField("有效期起 (YYYY-MM-DD)", text: $validFrom)
                    TextField("有效期止 (YYYY-MM-DD)", text: $validTo)
                    TextField("备注", text: $remarks)
                }
            }
            .navigationTitle("新增医保信息")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        table.insertInsurance(
                            patientId: patientId,
                            insuranceType: insuranceType,
                            insuranceNumber: insuranceNumber,
                            coverageScope: coverageScope,
                            validFrom: validFrom,
                            validTo: validTo,
                            remarks: remarks
                        )
                        onSave()
                        dismiss()
                    }
                    .disabled(insuranceType.isEmpty || insuranceNumber.isEmpty)
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
