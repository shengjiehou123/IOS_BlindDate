//
//  Me.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/3.
//

import SwiftUI
import SDWebImageSwiftUI

struct Me: View {
    @State var userInfoModel : ReCommandModel = ReCommandModel()
    @State var isFirst : Bool = true
    @State var push : Bool = false
    @State var tabbarVc : UITabBarController? = nil
    var body: some View {
//        Text("Hello, World!").onAppear {
//            requestUserInfo()
//        }
        NavigationView{
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height:20 + kSafeTop)
            HStack(alignment: .center, spacing: 10) {
                WebImage(url: URL.init(string: userInfoModel._avatar))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80, alignment: .center)
                    .background(Color.red)
                    .clipShape(Circle()).contentShape(Rectangle()).onTapGesture {
                        UserCenter.shared.LogOut()
                    }
                VStack(alignment: .leading, spacing: 5) {
                    Text(userInfoModel.nickName)
                        .font(.system(size: 20, weight: .medium, design: .default))
                    Button {
                        
                    } label: {
                        Text("资料待完善")
                            .foregroundColor(Color.black)
                            .font(.system(size: 15, weight: .medium, design: .default))
                    }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)).background(RoundedRectangle(cornerRadius: 5).fill(Color.white))

                    
                }
                Spacer()
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            MeVipEntranceView()
            NavigationLink {
                MyDynamicPage()
            } label: {
                MyDynamicView().frame(height:80).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).background(RoundedRectangle(cornerRadius: 5).fill(Color.white)).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            
            NavigationLink {
                VerifyListView()
            } label: {
                MeRow(title: "我的认证").frame(height:55).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).background(RoundedRectangle(cornerRadius: 5).fill(Color.white)).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            }
            
            NavigationLink {
                SettingView()
            } label: {
                MeRow(title: "设置").frame(height:55).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).background(RoundedRectangle(cornerRadius: 5).fill(Color.white)).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            }
          
            Spacer()
        }.navigationBarHidden(true).navigationBarTitleDisplayMode(.inline).preferredColorScheme(.light).background(Color.colorWithHexString(hex: "#F3F3F3")).ignoresSafeArea().introspectTabBarController(customize: { barVc in
            tabbarVc = barVc
        }).onAppear {
            tabbarVc?.tabBar.isHidden = false
            if !isFirst {
                return
            }
            isFirst = false
            requestUserInfo()
        }
     }
    }
    func requestUserInfo(){
        NW.request(urlStr: "get/user/info", method: .post, parameters: nil) { response in
            let dic = response.data
            guard let model = ReCommandModel.deserialize(from: dic, designatedPath: nil) else{
                return
            }
            userInfoModel = model
            log.info("nickName:\(model.nickName)")
        } failedHandler: { response in
            
        }

    }
}

//MARK: 我的动态
struct MyDynamicView:View{
    
    var body: some View{
        HStack(alignment: .center, spacing: 10) {
            Text("我的动态").foregroundColor(.black)
                .font(.system(size: 16))
            Spacer()
            Image("7x14right").resizable().aspectRatio( contentMode: .fill).frame(width: 7, height: 14, alignment: .leading)
            
        }
    }
}

//MARK: 我的认证
struct MeRow:View{
    var title : String
    var body: some View{
        HStack(alignment: .center, spacing: 10) {
            Text(title).foregroundColor(.black)
                .font(.system(size: 16))
            Spacer()
            Image("7x14right").resizable().aspectRatio( contentMode: .fill).frame(width: 7, height: 14, alignment: .leading)
        }
    }
}

struct MeVipEntranceView:View{
    var body: some View{
        GeometryReader { reader in
           let width = reader.size.width
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("VIP特权")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.white)
                    Text("无限滑卡")
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(.white)
                }.padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 0)).frame(width:(width - 30) / 2.0,alignment: .leading).background(RoundedRectangle(cornerRadius: 5).fill(btnLRLineGradient))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("查看谁喜欢我")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.white)
                    Text("60人待配对")
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(.white)
                }.padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 0)).frame(width:(width - 30) / 2.0,alignment: .leading).background(RoundedRectangle(cornerRadius: 5).fill(btnLRLineGradient))
                
            }.padding(EdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10))
        }.frame(height:100)
    }
}

struct Me_Previews: PreviewProvider {
    static var previews: some View {
        Me()
    }
}
