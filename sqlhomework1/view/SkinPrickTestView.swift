//
//  SkinPrickTestView.swift
//  sqlhomework1
//
//  Created by 郑金坝 on 2025/6/30.
//


import SwiftUI

struct SkinPrickTestView: View {
    let patientId: Int32

    var body: some View {
        VStack {
            Text("皮肤点刺试验")
                .font(.title2)
                .padding()
            Spacer()
            Text("这里将显示点刺试验数据")
                .foregroundColor(.gray)
                .italic()
            Spacer()
        }
    }
}
