//
//  CustomDatePicker.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/7.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var show : Bool
    @State var date : Date
    @Binding var selectionDate : Date
    var minDate : Date
    var maxDate : Date
    var displayedComponents :DatePickerComponents
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Text("取消").foregroundColor(.gray).padding(.leading,15).onTapGesture {
                    show = false
                }
                Spacer()
                Text("确定").foregroundColor(.blue).padding(.trailing,15).onTapGesture {
                    selectionDate = date
                    show = false
                }
            }.frame(height:45)
            DatePicker("", selection: $date,in: minDate...maxDate,displayedComponents: displayedComponents)
                .datePickerStyle(WheelDatePickerStyle())
                .environment(\.locale, Locale(identifier: "zh-CN"))
                .frame(height:200)
        }.background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3"))).offset(y:show ? 0 : 300).animation(.linear(duration: 0.25), value: show)
    }
}


