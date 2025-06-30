//
//  AddAllergenReportView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct AddAllergenReportView: View {
    let patientId: Int32
    let onSave: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    // 过敏原选中状态
    @State private var selectedAllergens: Set<String> = []
    
    // 每个过敏原对应的数值输入（字符串）
    @State private var allergenValues: [String: String] = [:]
    
    // 每个过敏原对应的结论
    @State private var allergenConclusions: [String: String] = [:]
    
    // 检查日期
    @State private var checkDate: Date = Date()
    
    // 备注
    @State private var remarks: String = ""
    
    // 结论选项
    let conclusions = ["阴性", "弱阳性", "阳性", "强阳性", "未判定"]
    
    // 数据库表对象
    let table = CheckReportsTable(db: DatabaseManager.shared.db)
    
    // 过敏原列表
    let allOptions = CheckReportFields.igEFields + CheckReportFields.allergenSingleFields
    
    var body: some View {
        NavigationStack {
            Form {
                Section("检查日期") {
                    DatePicker("选择日期", selection: $checkDate, displayedComponents: .date)
                }
                
                Section("选择过敏原") {
                    ForEach(allOptions, id: \.self) { allergen in
                        VStack(alignment: .leading, spacing: 6) {
                            Button(action: {
                                toggleSelection(allergen)
                            }) {
                                HStack {
                                    Text(allergen)
                                    Spacer()
                                    if selectedAllergens.contains(allergen) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            if selectedAllergens.contains(allergen) {
                                // 如果是IgE字段，显示数值输入框
                                if CheckReportFields.igEFields.contains(allergen) {
                                    TextField("请输入数值 (kU/L)", text: Binding(
                                        get: { allergenValues[allergen] ?? "" },
                                        set: { allergenValues[allergen] = $0 }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.leading)
                                }
                                
                                // 结论选择
                                Picker("判定结果", selection: Binding(
                                    get: { allergenConclusions[allergen] ?? conclusions[0] },
                                    set: { allergenConclusions[allergen] = $0 }
                                )) {
                                    ForEach(conclusions, id: \.self) { Text($0) }
                                }
                                .pickerStyle(.segmented)
                                .padding(.leading)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("备注") {
                    TextEditor(text: $remarks)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("新增过敏原检查")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveReport()
                    }
                    .disabled(selectedAllergens.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func toggleSelection(_ allergen: String) {
        if selectedAllergens.contains(allergen) {
            selectedAllergens.remove(allergen)
            allergenValues[allergen] = nil
            allergenConclusions[allergen] = nil
        } else {
            selectedAllergens.insert(allergen)
            // 设默认结论
            allergenConclusions[allergen] = conclusions[0]
        }
    }
    
    func saveReport() {
        // 组装字典结构：{ "过敏原名": {"value": "...", "conclusion": "..."}, ... }
        var dict: [String: [String: String]] = [:]
        
        for allergen in selectedAllergens {
            let value = allergenValues[allergen] ?? ""
            let conclusion = allergenConclusions[allergen] ?? conclusions[0]
            dict[allergen] = [
                "value": value,
                "conclusion": conclusion
            ]
        }
        
        guard let jsonData = try? JSONEncoder().encode(dict),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("JSON编码失败")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: checkDate)
        
        table.insertCheckReport(
            patientId: patientId,
            category: "过敏原",
            subType: "多选",
            checkDate: dateString,
            reportJson: jsonString,
            remarks: remarks
        )
        
        onSave()
        dismiss()
    }
}
