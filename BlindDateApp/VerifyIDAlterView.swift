//
//  VerifyIDAlterView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/8.
//

import SwiftUI

struct VerifyIDAlterView: View {
    @Binding var show : Bool
    @Binding var pushVerify : Bool
    var body: some View {
        ZStack{
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 20){
                Text("您还未实名认证，请实名认证").font(.system(size: 18,weight: .bold)).padding(.top,20)
                Text("认证后即可匹配其他实名认证用户").font(.system(size: 15))
                Button {
                    show = false
                    self.topViewController()?.dismiss(animated: false)
                    pushVerify = true
                } label: {
                    HStack{
                        Text("确定").foregroundColor(Color.white).font(.system(size: 16,weight: .medium)).padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)).background(RoundedRectangle(cornerRadius: 5).fill(btnLRLineGradient)).padding(.bottom,20)
                    }
                }.buttonStyle(PlainButtonStyle())

            }.frame(width:screenWidth - 100).background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        }
      
    }
}

struct VerifyIDAlterView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyIDAlterView(show: .constant(true),pushVerify: .constant(false))
    }
}
