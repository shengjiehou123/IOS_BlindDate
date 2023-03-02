//
//  RecommandList.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecommandList: View {
    init(){
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .white
//        requestRecommandList(state: .normal)
//        UIScrollView.appearance().bounces = false
    }
   
    @State var computedModel = ComputedProperty()
    @State var listData : [ReCommandModel] = []
    var body: some View {
//        Text("Hello, World!").onAppear {
////            requestRecommandList(state: .normal)
//        }
    NavigationView{
        ZStack(alignment: .top){
            ForEach(0..<listData.count,id:\.self){ index in
                let model = listData[index]
                ScrollCardView(bgColor: .orange, recommandModel: model,index: index)
            }
        }.navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Text("推荐").font(.system(size: 30, weight: .medium, design: .default))).modifier(LoadingView(isShowing: $computedModel.showLoading, bgColor: $computedModel.loadingBgColor)).toast(isShow: $computedModel.showToast, msg: computedModel.toastMsg)
    }.onAppear {
        requestRecommandList(state: .normal)
    }
            
        
    }
    
    func requestRecommandList(state:RefreshState){
        let param = ["page":1,"pageLimit":2]
        if state == .normal{
            computedModel.showLoading = true
            computedModel.loadingBgColor = .white
        }
        NW.request(urlStr: "recommended/list", method: .post, parameters: param) { response in
            computedModel.showLoading = false
            if state == .normal || state == .pullDown || state == .refresh {
                listData.removeAll()
            }
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            var tempArr : [ReCommandModel] = []

            for item in list {
                guard let recommandModel = ReCommandModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                tempArr.append(recommandModel)
            }
            listData.append(contentsOf: tempArr)
        } failedHandler: { response in
            computedModel.showLoading = false
            computedModel.showToast = true
            computedModel.toastMsg = response.message
        }

    }
}

struct ScrollCardView:View{
    var bgColor : Color
    var recommandModel : ReCommandModel
    var index:Int
    @State var offset : CGFloat = 0;
    @GestureState var isDragging : Bool = false
    @State var endSwipe : Bool = false
    
    var body: some View{
        let topOffset = index <= 2 ? index * 15 : 0
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                CardView(recommandModel: recommandModel, bgColor: bgColor)
                HomePageAboutUsView(title: "关于我",content: recommandModel.aboutMeDesc,userPhotos: recommandModel.userPhotos).padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10))
                HomePageAboutUsView(title: "希望对方",content: recommandModel.likePersonDesc,userPhotos: []).padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10))
            }
        }.navigationViewStyle(.automatic).background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)).padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
            .offset(x:offset,y:CGFloat(topOffset))
            .rotationEffect(.init(degrees: getRotation(angle: 8)))
            .gesture(DragGesture().updating($isDragging, body: { value, out, _ in
                out = true
            }).onChanged({ value in
                let translation = value.translation.width
                log.info("translationWidth\(translation)")
                offset = isDragging ? translation : .zero
            }).onEnded({ value in
                let translation = value.translation.width
                let checkingStatus = translation > 0 ? translation : -translation
                withAnimation {
                    if checkingStatus > screenWidth / 2 {
                        //delete card
                        offset = (translation > 0 ? screenWidth: -screenWidth) * 2
                        if translation > 0 {
                            //rightswipe
                            
                        }else{
                            //leftswipe
                            
                        }
                    }else{
                        offset = .zero
                    }
                }
    
            })
            )
    }
    
    // 旋转
    func getRotation(angle: Double)-> Double{
        let rotation = (offset / (screenWidth - 50)) * angle
        return rotation
    }
    
    
}


struct HomePageAboutUsView:View{
    var title : String
    var content: String
    var userPhotos:[UserPhotoModel]
    var body: some View{
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 0) {
                Text(title)
                    .foregroundColor(.gray)
                    .font(.system(size: 17, weight: .medium, design: .default))
                Spacer()
            }
            Text(content).lineSpacing(5)
            
            ForEach(userPhotos,id:\.uid) { model in
                let photo = model.photo
                let url = URL.init(string:photo)
                WebImage(url: url).resizable().aspectRatio(contentMode: .fill).frame(width: screenWidth - 40, height: 330, alignment: .leading)
                        .clipped()
            }
            
        }
        
    }
}

struct CardView:View{
    var recommandModel : ReCommandModel
    var bgColor : Color
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
           CardHeaderView(recommandModel: recommandModel, bgColor: bgColor)
//            Spacer()
        }
    }
}

struct CardHeaderView:View{
    var recommandModel : ReCommandModel
    @State var titles = ["163cm","电商","搞笑女孩","搞笑女孩2","搞笑女孩3"]
    @State var sumWidth : CGFloat = 0
    @State var overParentWidthDic :[Int:[String]] = [:]
    @State var rows :[Int] = []
    var bgColor : Color
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0, content: {
                let avatarUrl = URL(string: recommandModel.avatar)
                WebImage(url: avatarUrl).resizable().aspectRatio(contentMode: .fill).background(Color.gray).frame(width: 80, height: 80, alignment: .leading).clipShape(Circle())
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 10) {
                        Text( recommandModel.nickName)
                            .foregroundColor(.white)
                        let birthDayDate =  Date.init(timeIntervalSince1970: recommandModel.birthday)
                        
                        Text("\(birthDayDate.getAge())")
                            .foregroundColor(.white)
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    HStack(alignment: .center, spacing: 10) {
                        Image("arkit").resizable().frame(width: 20, height: 20, alignment: .leading).background(Color.red).padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 4))
                        Text("实名 真实头像")
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 4))
                    }.background(RoundedRectangle(cornerRadius: 4).fill(Color.orange)).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                   

                }
                Spacer()
            }).background(Color.blue).padding(EdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 0))
            ForEach(rows,id:\.self){ row in
                let titleContents = overParentWidthDic[row] ?? []
                HStack(alignment: .top, spacing: 10) {
                    ForEach(titleContents,id:\.self){ title in
                        BackColorText(title: title)
                    }
                }.padding(EdgeInsets(top: 20, leading: 10, bottom:row == rows.count - 1 ? 20 : 0, trailing: 10))
            }
            
            
//            Spacer()
        }.background(RoundedRectangle(cornerRadius: 10).fill(bgColor)).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).onAppear {
            sortTitles()
        }
    }
    
    func sortTitles(){
        rows.removeAll()
        getNextRowTitles(row: 0, titles: titles)
        log.info("overParentWidthDic:\(overParentWidthDic)")
    }
    
    func getNextRowTitles(row:Int,titles:[String]){
        var normalRowTitles : [String] = []
        var nextRowTitles : [String] = []
        for (index,item) in titles.enumerated() {
            let tuple = calTextWidth(index: index, title: item, font: UIFont.systemFont(ofSize: 17))
            let textContent = tuple.1
            if !textContent.isEmpty {
                nextRowTitles.append(textContent)
            }else{
                normalRowTitles.append(item)
            }
        }
        overParentWidthDic[row] = normalRowTitles
        rows.append(row)
        if !nextRowTitles.isEmpty {
            getNextRowTitles(row: row + 1, titles: nextRowTitles)
        }
    }
    
    func calTextWidth(index:Int,title:String,font:UIFont) ->(index:Int,title:String){
        let width = title.size(withAttributes: [NSAttributedString.Key.font : font]).width + 7 + 7
        if index == 0 {
            sumWidth = 0
        }
        sumWidth += ((index == 0) ? 10 + width : width)
        if sumWidth > screenWidth - 40 {
            return (index,title)
        }
        return (index,"")
    }
}

struct BackColorText:View{
    var title:String = ""
    var body: some View{
        Text(title).lineLimit(1).padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)).background(Capsule().fill(Color.black.opacity(0.2)))
    }
}

struct RecommandList_Previews: PreviewProvider {
    static var previews: some View {
        RecommandList()
    }
}
