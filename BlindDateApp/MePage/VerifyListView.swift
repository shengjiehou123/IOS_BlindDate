//
//  VerifyListView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/15.
//

import SwiftUI

struct VerifyListView: View {
    var body: some View {
            ScrollView(.vertical,showsIndicators: false){
                VStack(alignment:.leading){
                    HStack{
                        Text("*完成认证后可以点亮相应的标识,信息真实度越高，越容易获得对方的青睐~").font(.system(size: 13)
                        ).foregroundColor(.red)
                         .lineSpacing(3)
                    }.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    VStack(alignment: .leading,spacing: 10){
                        let arr : [[String:Any]] = [
                            ["title":"实名认证","content":"通过公安系统验证真实性","image":"verify_id","verified":UserCenter.shared.userInfoModel?.idVerifyed ?? 0],
                            ["title":"头像认证","content":"通过人脸比对，验证用户头像为本人照片","image":"avatar","verified":0]
                        ]
                        ForEach(0..<arr.count,id:\.self){ index in
                            let item = arr[index]
                            VerifyItem(item: item)
                        }

                    }.padding(EdgeInsets(top:0, leading: 20, bottom: 0, trailing: 20))
                  
                }
            }.modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "我的认证"))
            .background(Color.colorWithHexString(hex: "F3F3F3")).ignoresSafeArea(.container,edges: .bottom)
        }
       
}

struct VerifyItem :View{
    var item : [String:Any]
    @State var  verified : Int = 0
    var body: some View{
        HStack(alignment: .center) {
            ZStack{
                Color.clear.frame(width:40,height:40).background(Circle().fill(Color.colorWithHexString(hex: "E7F3FF")))
                Image(item["image"] as? String ?? "").resizable().aspectRatio(contentMode: .fill)
                    .frame(width:20,height:20,alignment: .center)
            }.padding(.leading,10)
            VStack(alignment: .leading,spacing: 5){
                Text(item["title"] as? String ?? "").font(.system(size: 15,weight: .bold))
                Text(item["content"] as? String ?? "").font(.system(size: 13)).foregroundColor(.colorWithHexString(hex: "99999"))
            }.padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            Spacer()
            
            Button {
                if verified == 0{
                    
                }
            } label: {
                Text(verified > 0 ? "已认证" : "未认证").foregroundColor(verified > 0 ? .black : .white).font(.system(size: 14,weight: .bold)).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)).background(Capsule().fill(verified > 0 ? LinearGradient.linearGradient(Gradient(colors: [ Color.colorWithHexString(hex: "F3F3F3") ]),startPoint: .leading,endPoint: .trailing): btnLRLineGradient)).padding(.trailing,10)
            }.buttonStyle(PlainButtonStyle())

        }.background(RoundedRectangle(cornerRadius: 10).fill(Color.white)).onAppear{
            verified = item["verified"] as? Int ?? 0
        }
    }
}

struct VerifyListView_Previews: PreviewProvider {
    static var previews: some View {

        VerifyListView()

       
    }
}
