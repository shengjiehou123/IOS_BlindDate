//
//  LikeMe.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/3.
//

import SwiftUI
import SDWebImageSwiftUI

class LikeMeViewModel:ObservableObject{
    @Published var listData : [LikeMeModel] = []
    @Published var total : Int = 0
    func requestLikeMeList(state:RefreshState){
        let param = ["page":1,"pageLimit":10]
        NW.request(urlStr: "like/me/list", method: .post, parameters: param) { response in
            if state == .normal || state == .pullDown || state == .refresh {
                self.listData.removeAll()
            }
            let total = response.data["total"] as? Int ?? 0
            self.total = total
            guard let list = response.data["likeMeList"] as? [[String:Any]] else{
                return
            }
            var temArr : [LikeMeModel] = []
            for dic in list {
                guard let model = LikeMeModel.deserialize(from: dic, designatedPath: nil) else{
                    continue
                }
                temArr.append(model)
            }
            
            self.listData.append(contentsOf: temArr)
//            for index in 0..<20{
//                let model = LikeMeModel()
//                model.id = 200 + index
//                model.avatar = "http://rq1wxldn4.hb-bkt.clouddn.com/c4e1985611383dcd742a35a0a0530e8b/avatar/IMG_3419.jpg"
//                self.listData.append(model)
//            }
           
            
        } failedHandler: { response in
            
        }

    }
}

struct LikeMe: View {
    @ObservedObject var model : LikeMeViewModel = LikeMeViewModel()
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false) {
                if model.total > 0 {
                    VStack(alignment: .center, spacing: 10){
                        Spacer().frame(height:10)
                        Text("开通特权，立即解锁喜欢你的人")
                            .font(.system(size: 17, weight: .medium, design: .default))
                        Text("有\(model.total)人正在等待你的回应").font(.system(size: 17, weight: .medium, design: .default))
                    }
                }
                
                let items = [GridItem(.flexible()),GridItem(.flexible())]
                LazyVGrid(columns: items,spacing: 10) {
                    ForEach(model.listData,id:\.id){ model in
                        WebImage(url: URL(string: model.avatar)).resizable().aspectRatio( contentMode: .fill).frame(height:250).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            }.navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if model.total > 0 {
                            Text("\(model.total)人喜欢我")
                                .font(.system(size: 25, weight: .medium, design: .default))
                        }
                    }
                }.onAppear {
                    model.requestLikeMeList(state: .normal)
                }
        }
          
        
    }
}

struct LikeMe_Previews: PreviewProvider {
    static var previews: some View {
        LikeMe()
    }
}
