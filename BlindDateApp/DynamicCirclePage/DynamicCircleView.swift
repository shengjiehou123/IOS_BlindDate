//
//  DynamicCircle.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/15.
//

import SwiftUI
import SDWebImageSwiftUI
import HandyJSON

class CircleModel:HandyJSON{
    var uid : Int = 0
    var avatar : String = ""
    var nickName : String = ""
    var birthday : Double = 0
    var workCityName : String = ""
    var job : String = ""
    var content : String = ""
    var images : String = ""
    required init() {
        
    }
}

struct DynamicCircleView: View {
    @State var listData : [CircleModel] = []
    var body: some View {
     NavigationView{
        ScrollView(.vertical,showsIndicators: false){
            LazyVStack(alignment:.leading,spacing:30){
                ForEach(listData,id:\.uid){ model in
                    CircleRow(model:model)
                }
            }
        }.modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "")).navigationBarTitleDisplayMode(.inline).toolbar(content:{
            ToolbarItem(placement:.navigationBarLeading){
                Text("广场").font(.system(size:25,weight:.medium))
            }
        }).onAppear {
            requestCircleList()
        }
    }
  }
    
    func requestCircleList(){
        NW.request(urlStr: "circle/list", method: .post, parameters: nil) { response in
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            listData.removeAll()
            for item in list {
                guard let model = CircleModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                listData.append(model)
            }
            
        } failedHandler: { response in
            
        }

    }
}

struct CircleRow:View{
    var model : CircleModel
    @State var images: [String] = []
    var body: some View{
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                WebImage(url: URL(string:model.avatar)).resizable().aspectRatio( contentMode: .fill).frame(width: 40, height: 40, alignment: .center).background(Color.red).clipShape(Circle())
                VStack(alignment: .leading, spacing: 5){
                    Text(model.nickName).font(.system(size: 13,weight:.medium))
                    HStack(alignment: .center, spacing: 3){
                        Text("\(Date.init(timeIntervalSince1970: model.birthday).getAge())").font(.system(size: 13)).foregroundColor(.gray)
                        Text(model.workCityName).font(.system(size: 13)).foregroundColor(.gray)
                        Text(model.job).font(.system(size: 13)).foregroundColor(.gray)
                    }
                }
                Spacer()
            }.frame(maxWidth:.infinity).padding(.leading,15)
            
            HStack(alignment: .center, spacing: 0){
                Spacer().frame(width:40)
                Text(model.content).lineSpacing(10)
                Spacer()
            }.frame(maxWidth:.infinity).padding(.leading,15)
            VStack(alignment: .leading, spacing: 10){
                
                ForEach(0..<getRow(total: images.count)){ i in
                    HStack(alignment: .center,spacing: 10){
                        ForEach(0..<3){ j in
                            if getIndex(i: i, j: j) < images.count {
                                WebImage(url:URL(string:"\(images[getIndex(i:i,j:j)])")).resizable().aspectRatio( contentMode: .fill).background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
                                    .frame(width:100,height:100).clipShape(RoundedRectangle(cornerRadius: 10))
                            }else{
                                EmptyView()
                            }
                        }
                    }
                    }.padding(.horizontal)
                Spacer()
            }.padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 10))
            HStack(alignment:.center,spacing:50){
                Spacer()
                Text("点赞")
                Text("评论")
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            
        }.onAppear {
            images = model.images.components(separatedBy: ",")
        }
    }
    
    func getRow(total:Int) ->Int{
        return (total-1) / 3 + 1
    }
    
    func getIndex(i:Int,j:Int) ->Int{
        let index = i*3 + j
        return index
    }
}





struct DynamicCircle_Previews: PreviewProvider {
    static var previews: some View {
        DynamicCircleView()
    }
}
