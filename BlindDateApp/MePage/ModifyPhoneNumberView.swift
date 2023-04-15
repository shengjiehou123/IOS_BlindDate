//
//  ModifyPhoneNumberView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/15.
//

import SwiftUI

struct ModifyPhoneNumberView: View {
    @State var code : String = ""
    @State var push  = false
    var body: some View {
        VStack(alignment: .leading,spacing: 15){
            let str = String.init(format: "向手机号%@发送了验证码", UserCenter.shared.userInfoModel?.phoneNumber ?? "")
            Text(str).font(.system(size: 14))
            TextField("输入验证码", text: $code).textFieldStyle(PlainTextFieldStyle()).padding(.leading,7).frame(height:50).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "E3E3E3"))).keyboardType(.numberPad)
            
            Spacer().frame(height:30)
            NavigationLink(destination: NewPhoneNumberView(), isActive: $push) {
                EmptyView()
            }
            NextStepButton(title: "下一步") {
                push = true
            }

            Spacer()
        }.modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "修改手机号")).padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
        
    }
}

struct ModifyPhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ModifyPhoneNumberView()
        }
       
    }
}
