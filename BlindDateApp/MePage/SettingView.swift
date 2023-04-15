//
//  SettingView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/15.
//

import SwiftUI

struct SettingView: View {
    @State var showLogOutAlter : Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            NavigationLink {
                ModifyPhoneNumberView()
            } label: {
                SettingRow(title: "账号与安全")
            }

            LineHorizontalView()
            SettingRow(title: "帮助与反馈")
            LineHorizontalView()
            SettingRow(title: "关于加一")
            Button {
                 showLogOutAlter = true
            } label: {
                HStack{
                    Spacer()
                    Text("退出登录").foregroundColor(.black)
                    Spacer()
                }.contentShape(Rectangle()).frame(height:55).background(Color.white).padding(.top,10)
            }.alert(isPresented: $showLogOutAlter) {
                Alert(title: Text("确定要退出登录么？"), message: nil,
                    primaryButton: .default(
                        Text("取消"),
                        action: {
                            
                        }
                    ),
                    secondaryButton: .destructive(
                        Text("确定"),
                        action: {
                            UserCenter.shared.LogOut()
                        }
                    ))
            }
            Spacer()

        }.modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "设置")).background(Color.colorWithHexString(hex: "F3F3F3"))
    }
}



struct SettingRow:View{
    var title : String
    var body: some View{
        HStack(alignment: .center, spacing: 10) {
            Text(title).foregroundColor(.black)
                .font(.system(size: 15)).padding(.leading,20)
            Spacer()
            Image("7x14right").resizable().aspectRatio( contentMode: .fill).frame(width: 7, height: 14, alignment: .leading).padding(.trailing,20)
        }.frame(maxWidth:.infinity,maxHeight: 55).background(Color.white)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
