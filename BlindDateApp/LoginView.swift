//
//  LoginView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/14.
//

import SwiftUI

struct LoginView: View {
    @State var phoneNumber: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            Spacer().frame(height:20)
            HStack(alignment: .center, spacing: 0) {
                Text("手机登录")
                    .font(.system(size: 20, weight: .medium, design: .default))
                Spacer()
            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
            Spacer().frame(height:20)
            HStack(alignment: .center, spacing: 0) {
                TextField.init("请输入手机号", text: $phoneNumber).textFieldStyle(.plain).accentColor(.orange).frame(maxWidth:.infinity,maxHeight:44).background(RoundedRectangle(cornerRadius: 5).stroke(.gray,style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            
            Spacer().frame(height:20)
            HStack(alignment: .center, spacing: 0) {
                TextField.init("请输入验证码", text: $phoneNumber).textFieldStyle(.plain).accentColor(.orange).frame(maxWidth:.infinity,maxHeight:44).background(RoundedRectangle(cornerRadius: 5).stroke(.gray,style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            Spacer().frame(height:30)
            Button {
                
            } label: {
                Text("Login").foregroundColor(.white)
            }.frame(maxWidth:.infinity,maxHeight: 44).background(RoundedRectangle(cornerRadius: 5).fill(.blue)).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

            Spacer()
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
