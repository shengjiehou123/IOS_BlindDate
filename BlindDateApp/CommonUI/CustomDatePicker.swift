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
    var selectedDate : (_ seletedDate:Date) ->Void
    @State  var showPicker : Bool = false
    var body: some View {
        if show {
            ZStack(alignment: .bottomLeading) {
             Color.black.opacity(0.3).frame(maxWidth:.infinity,maxHeight: .infinity)
             VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text("取消").foregroundColor(.gray).padding(.leading,15).onTapGesture {
                        showPicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            show = false
                            topViewController()?.dismiss(animated: true, completion: nil)
                        }
                    }
                    Spacer()
                    Text("确定").foregroundColor(.blue).padding(.trailing,15).onTapGesture {
                        selectionDate = date
                        showPicker = false
                        selectedDate(selectionDate)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            show = false
                            topViewController()?.dismiss(animated: true, completion: nil)
                        }
                    }
                }.frame(height:45)
                 DatePicker("",selection: $date, in: minDate...maxDate, displayedComponents: displayedComponents).labelsHidden().datePickerStyle(WheelDatePickerStyle())
                     .environment(\.locale, Locale(identifier: "zh-CN"))
                     .frame(maxWidth:.infinity,maxHeight:200).background(Color.white)
                 
//                 DatePicker(selection: $date,in: minDate...maxDate,displayedComponents: displayedComponents)
                   
            }.background(RoundedRectangle(cornerRadius: 5).fill(Color.white)).offset(y:showPicker ? 0 : 300).animation(.linear(duration: 0.25), value: showPicker).onAppear {
                showPicker = show
                date = selectionDate
            }
          }.edgesIgnoringSafeArea(.top)
        }
    }
}


