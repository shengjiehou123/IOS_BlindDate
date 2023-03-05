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
    var body: some View {
//        Text("Hello, World!").onAppear {
//            requestUserInfo()
//        }
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height:20)
            HStack(alignment: .center, spacing: 10) {
                WebImage(url: URL.init(string: userInfoModel.avatar))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80, alignment: .leading)
                    .background(Color.red)
                    .clipShape(Circle(), style: .init(eoFill: true, antialiased: true))
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
            Spacer()
        }.background(Color.black.opacity(0.1)).onAppear {
            requestUserInfo()
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
                }.padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 0)).frame(width:(width - 30) / 2.0,alignment: .leading).background(RoundedRectangle(cornerRadius: 5).fill(Color.red))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("查看谁喜欢我")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.white)
                    Text("60人待配对")
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(.white)
                }.padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 0)).frame(width:(width - 30) / 2.0,alignment: .leading).background(RoundedRectangle(cornerRadius: 5).fill(Color.red))
                
            }.padding(EdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10))
        }
    }
}

struct Me_Previews: PreviewProvider {
    static var previews: some View {
        Me()
    }
}
