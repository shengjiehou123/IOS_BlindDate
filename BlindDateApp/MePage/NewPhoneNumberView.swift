//
//  NewPhoneNumberView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/15.
//

import SwiftUI

struct NewPhoneNumberView: View {
    @State var phoneNumber : String = ""
    @State var code : String = ""
    var body: some View {
        VStack(alignment: .leading,spacing: 15){
            Text("新手机号").font(.system(size: 14))
            HStack(alignment: .center, spacing: 3){
                TextField("输入新手机号", text: $phoneNumber).textFieldStyle(PlainTextFieldStyle()).padding(.leading,7).frame(height:50).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "E3E3E3"))).keyboardType(.phonePad)
                Spacer()
                Button {
                    
                } label: {
                    Text("获取验证码").foregroundColor(.white).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)).frame(height:50).background(RoundedRectangle(cornerRadius: 5 ).fill(btnLRLineGradient))
                }

            }
            
            HStack(alignment: .center, spacing: 3){
                TextField("输入验证码", text: $code).textFieldStyle(PlainTextFieldStyle()).padding(.leading,7).frame(height:50).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "E3E3E3"))).keyboardType(.phonePad)
            }
           
            
            Spacer().frame(height:20)
            NextStepButton(title: "下一步") {
                
            }

            Spacer()
        }.modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "修改手机号")).padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
    }
}

struct NewPhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            NewPhoneNumberView()
        }
    }
}
