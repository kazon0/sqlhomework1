//
//  EditInsuranceView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct EditInsuranceView: View {
    @State var insurance: Insurance
    let onSave: () -> Void
    let table = InsuranceTable(db: DatabaseManager.shared.db)

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("医保信息")) {
                    TextField("医保类型", text: $insurance.insuranceType)
                    TextField("医保卡号", text: $insurance.insuranceNumber)
                    TextField("报销范围", text: $insurance.coverageScope)
                    TextField("有效期起 (YYYY-MM-DD)", text: $insurance.validFrom)
                    TextField("有效期止 (YYYY-MM-DD)", text: $insurance.validTo)
                    TextField("备注", text: Binding($insurance.remarks, default: ""))
                }
            }
            .navigationTitle("编辑医保信息")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        table.updateInsurance(
                            id: insurance.id,
                            insuranceType: insurance.insuranceType,
                            insuranceNumber: insurance.insuranceNumber,
                            coverageScope: insurance.coverageScope,
                            validFrom: insurance.validFrom,
                            validTo: insurance.validTo,
                            remarks: insurance.remarks ?? ""
                        )
                        onSave()
                        dismiss()
                    }
                    .disabled(insurance.insuranceType.isEmpty || insurance.insuranceNumber.isEmpty)
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

extension Binding where Value == String {
    /// 方便 Optional String 绑定
    init(_ source: Binding<String?>, default defaultValue: String) {
        self.init(get: {
            source.wrappedValue ?? defaultValue
        }, set: {
            source.wrappedValue = $0
        })
    }
}
