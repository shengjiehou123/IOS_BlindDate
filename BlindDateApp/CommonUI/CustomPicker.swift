//
//  CustomPicker.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/7.
//

import SwiftUI

struct CustomPicker: View {
   @Binding var show :Bool
   @Binding var selection : Int
   @State   var showPicker : Bool = false
   @State   var tempSelection : Int = 0
   var contentArr :[String]
    var body: some View {
        if show {
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text("取消").foregroundColor(.gray).padding(.leading,15).onTapGesture {
                        showPicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            show = false
                        }
                    }
                    Spacer()
                    Text("确定").foregroundColor(.blue).padding(.trailing,15).onTapGesture {
                        selection = tempSelection
                        showPicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            show = false
                        }
                        log.info("selectionHeight:\(selection)")
                    }
                }.frame(height:45)
                Picker("", selection: $tempSelection) {
                    ForEach(0..<contentArr.count){ index in
                        let content = contentArr[index]
                        Text(content)
                    }
                }.pickerStyle(WheelPickerStyle()).frame(height:200)
            }.background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3"))).offset(y:showPicker ? 0 : 300).animation(.linear(duration: 0.25), value: showPicker).onAppear {
                showPicker = show
                tempSelection = selection
            }
        }
    }
}

struct CustomPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomPicker(show:.constant(true),selection: .constant(0), contentArr: getHeightArr())
    }
    
    static func getHeightArr() -> [String]{
        var tempArr : [String] = []
        for height in 140...210 {
            let str = "\(height)cm"
            tempArr.append(str)
        }
        return tempArr
    }
}
