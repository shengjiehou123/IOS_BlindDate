//
//  LoginView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/14.
//

import SwiftUI
import Alamofire

struct LoginView: View {
    @State var phoneNumber: String = ""
    @State var code: String = ""
    @State var codeKey : String = ""
    @ObservedObject var computedModel = ComputedProperty()
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
                TextField.init("请输入验证码", text: $code).textFieldStyle(.plain).accentColor(.orange).frame(maxWidth:.infinity,maxHeight:44).background(RoundedRectangle(cornerRadius: 5).stroke(.gray,style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                Spacer()
                Button {
                    requestSendCode()
                } label: {
                    Text("获取验证码")
                        .font(.system(size: 15))
                        .foregroundColor(.white).padding()
                }.frame(maxHeight: 44).background(RoundedRectangle(cornerRadius: 5).fill(.blue)).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))

            }
            Spacer().frame(height:30)
            Button {
                requestLogin()
            } label: {
                Text("Login").foregroundColor(.white)
            }.frame(maxWidth:.infinity,maxHeight: 44).background(RoundedRectangle(cornerRadius: 5).fill(.blue)).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

            Spacer()
        }).modifier(LoadingView(isShowing: $computedModel.showLoading, bgColor: $computedModel.loadingBgColor))
    }
    
    func requestSendCode(){
        let param = ["phone_number":phoneNumber,"code":code]
        computedModel.showLoading = true
        NW.request(urlStr: "send/code", method: .post, parameters: param) { response in
            computedModel.showLoading = false
           codeKey = response.data["codeKey"] as? String ?? ""
        } failedHandler: { response in
            
        }

    }
    
    func requestLogin(){
        let param = ["phone_number":phoneNumber,"code":code,"codeKey":codeKey]
        NW.request(urlStr: "login", method: .post, parameters: param) { response in
           let token = response.data["token"] as? String ?? ""
           UserCenter.shared.saveToken(token: token)
        } failedHandler: { response in
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
