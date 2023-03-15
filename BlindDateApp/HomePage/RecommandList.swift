//
//  RecommandList.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI
import SDWebImageSwiftUI
import JFHeroBrowser


class RecommandData:ObservableObject{
    var id : UUID = UUID()
    @Published var listData : [ReCommandModel] = []
}

struct RecommandList: View {
    @State var computedModel = ComputedProperty()
    @StateObject var recommnadData : RecommandData = RecommandData()
    var body: some View {
//        Text("Hello, World!").onAppear {
////            requestRecommandList(state: .normal)
//        }
    NavigationView{
        ZStack(alignment: .top){
            ForEach(0..<recommnadData.listData.count,id:\.self){ index in
                let model = recommnadData.listData[index]
                ScrollCardView(bgColor: .orange,index: index).environmentObject(model)
            }
        }.navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Text("推荐").font(.system(size: 30, weight: .medium, design: .default))).modifier(LoadingView(isShowing: $computedModel.showLoading, bgColor: $computedModel.loadingBgColor)).toast(isShow: $computedModel.showToast, msg: computedModel.toastMsg)
    }.onAppear {
        requestRecommandList(state: .normal)
    }.onDisappear {
        
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
                recommnadData.listData.removeAll()
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
            recommnadData.listData.append(contentsOf: tempArr)
        } failedHandler: { response in
            computedModel.showLoading = false
            computedModel.showToast = true
            computedModel.toastMsg = response.message
        }

    }
}

struct ScrollCardView:View{
    var bgColor : Color
    @EnvironmentObject var recommandModel : ReCommandModel
    var index:Int
    @State var offset : CGFloat = 0;
    @GestureState var isDragging : Bool = false
    @State var endSwipe : Bool = false
    @State var likeUseAvatar : String = ""
    @State var showLikeEachOther : Bool = false
    var body: some View{
        let topOffset = index <= 2 ? index * 15 : 0
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                CardView(bgColor: bgColor).environmentObject(recommandModel)
                HomePageAboutUsView(title: "关于我",content: recommandModel.myTag.count > 0 ? (recommandModel.aboutMeDesc + "\n" + recommandModel.myTag) : recommandModel.aboutMeDesc,userPhotos: recommandModel.userPhotos)
                HomePageAboutUsView(title: "希望对方",content: recommandModel.likePersonTag,userPhotos: [])
                if !recommandModel.loveGoalsDesc.isEmpty {
                    HomePageAboutUsView(title: "恋爱目标",content: recommandModel.loveGoalsDesc,userPhotos: [])
                }
                
            }.introspectScrollView(customize: { scrollView in
                scrollView.bounces = false
            })
//            .cornerRadius(10).clipped()
        }.navigationViewStyle(.stack).clipShape(RoundedRectangle(cornerRadius: 10)).background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)).padding(EdgeInsets(top: 0, leading: 10, bottom: CGFloat(topOffset) + 10, trailing: 10))
            .offset(x:offset,y:CGFloat(topOffset))
            .rotationEffect(.init(degrees: getRotation(angle: 8)),anchor: .bottom)
            .delaysTouches(for: 0.1, onTap: {
                
            }).alertB(isPresented: $showLikeEachOther, builder: {
                LikeEachOtherView(isShow: $showLikeEachOther,avatar: UserCenter.shared.userInfoModel?.avatar ?? "",likeUserAvatar: recommandModel.avatar,toUserId: recommandModel.id)
            }).gesture(DragGesture().updating($isDragging, body: { value, out, _ in
                out = true
            }).onChanged({ value in
                let translation = value.translation.width
                log.info("translationWidth\(translation)")
                offset = isDragging ? translation : .zero
            }).onEnded({ value in
                let translation = value.translation.width
                let checkingStatus = translation > 0 ? translation : -translation
                withAnimation {
                    if checkingStatus > 50{
                        //delete card
                        offset = (translation > 0 ? screenWidth: -screenWidth) * 2
                        if translation > 0 {
                            //rightswipe
                            //like
                            requestLikePerson(toUserId: recommandModel.id, like: true)
                            
                        }else{
                            //leftswipe
                            //not like
                            requestLikePerson(toUserId: recommandModel.id, like: false)
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
    
    func requestLikePerson(toUserId:Int,like:Bool){
        let param = ["toUserId":toUserId,"like":like] as [String : Any]
        NW.request(urlStr: "like/person", method: .post, parameters: param) { response in
            let dic = response.data
//            let likeUserid = dic["likeUserId"]
            guard let likeUserAvatar = dic["likeUseAvatar"] as? String else{
                likeUseAvatar = ""
                return
            }
            likeUseAvatar = likeUserAvatar
            if !likeUserAvatar.isEmpty {
                showLikeEachOther = true
            }
        } failedHandler: { response in
        
        }

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
                    .font(.system(size: 15, weight: .medium, design: .default))
                Spacer()
            }.padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10))
            Text(content).lineSpacing(10).font(.system(size: 17)).padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
            
            ForEach(0..<userPhotos.count) { index in
                let model = userPhotos[index]
                let url = URL.init(string:model.photo)
                Spacer().frame(height:10)
                WebImage(url: url).resizable().interpolation(.high).aspectRatio(contentMode:.fill).frame(width: screenWidth - 20, height: 500, alignment: .center)
                    .clipped(antialiased: true).contentShape(Rectangle()).onTapGesture {
                   var list: [HeroBrowserViewModule] = []
                   for i in 0..<userPhotos.count {
                       let photoModel = userPhotos[i]
                       list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: photoModel.photo, originImgUrl: photoModel.photo))
                   }
                   myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                }
            }
            
        }.clipped(antialiased: true)
        
    }
}

struct CardView:View{
    @EnvironmentObject var recommandModel : ReCommandModel
    var bgColor : Color
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
//            Spacer().frame(height:10)
            CardHeaderView(bgColor: bgColor).environmentObject(recommandModel)
//            Spacer()
        }
    }
}

struct CardHeaderView:View{
    @EnvironmentObject var recommandModel : ReCommandModel
    @State var titles : [String] = []
    @State var sumWidth : CGFloat = 0
    @State var overParentWidthDic :[Int:[String]] = [:]
    @State var rows :[Int] = []
    var bgColor : Color
    var body: some View{
        ZStack(alignment: .top) {
            GeometryReader { reader in
                let size = reader.size
                WebImage(url: URL(string: recommandModel.bgImageUrl)).resizable().aspectRatio(contentMode: .fill).frame(width: size.width, height: size.height, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10))
            }
       
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0, content: {
                let avatarUrl = URL(string: recommandModel.avatar)
                WebImage(url: avatarUrl).resizable().aspectRatio(contentMode: .fill).background(Color.gray).frame(width: 80, height: 80, alignment: .leading).clipShape(Circle())
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 10) {
                        Text( recommandModel.nickName)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium, design: .default))
                        let birthDayDate =  Date.init(timeIntervalSince1970: recommandModel.birthday)
                        
                        Text("\(birthDayDate.getAge())")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium, design: .default))
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    HStack(alignment: .center, spacing: 10) {
//                        Image(systemName:"arkit").resizable().frame(width: 20, height: 20, alignment: .leading).background(Color.red).padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 4))
                        Text("实名 真实头像")
                            .font(.system(size: 13,weight: .medium))
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    }.background(RoundedRectangle(cornerRadius: 4).fill(Color.blue)).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                   

                }
                Spacer()
            }).padding(EdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 0))
            ForEach(rows,id:\.self){ row in
                let titleContents = overParentWidthDic[row] ?? []
                HStack(alignment: .top, spacing: 10) {
                    ForEach(titleContents,id:\.self){ title in
                        BackColorText(title: title)
                    }
                }.padding(EdgeInsets(top: 20, leading: 10, bottom:row == rows.count - 1 ? 20 : 0, trailing: 10))
            }
            
            
//            Spacer()
        }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)).onAppear {
            if !recommandModel.school.isEmpty {
                titles = ["\(recommandModel.height)cm",recommandModel.educationTypeDesc,recommandModel.school,recommandModel.job]
            }else{
                titles = ["\(recommandModel.height)cm",recommandModel.educationTypeDesc,recommandModel.job]
            }
            sortTitles()
            
        }
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
        Text(title).foregroundColor(.white).font(.system(size: 14)).lineLimit(1).padding(EdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10)).background(Capsule().fill(Color.black.opacity(0.4)))
    }
}

//MARK: 互相喜欢View
struct LikeEachOtherView:View{
    @Binding var isShow : Bool
    var avatar : String
    var likeUserAvatar : String
    var toUserId : Int
    @State var isShowAnimation : Bool = false
    var body: some View{
        if isShow {
        VStack(alignment: .center, spacing: 20) {
            Spacer().frame(height:100)
            HStack(alignment: .center, spacing: -10) {
                WebImage(url: URL(string: likeUserAvatar)).resizable().aspectRatio( contentMode: .fill).frame(width: 100, height: 100, alignment: .center).clipShape(Circle()).contentShape(Rectangle()).offset(x: isShowAnimation ? 0 : -50).animation(.spring(response: 0.5, dampingFraction: 0.3, blendDuration: 0.2), value: isShowAnimation).zIndex(1)
        
                WebImage(url:  URL(string: avatar)).resizable().aspectRatio( contentMode: .fill).clipShape(Circle()).frame(width: 100, height: 100, alignment: .center).offset(x: isShowAnimation ? 0 :  50).animation(.spring(response: 0.5, dampingFraction: 0.3, blendDuration: 0.2), value: isShowAnimation)
            }
            Text("你们相互喜欢了对方").font(.system(size: 22, weight: .medium, design: .default))
            Text("配对成功，可以开始聊天啦").font(.system(size: 18, weight: .medium, design: .default))
            Spacer().frame(height:50)
            
            Button {
                isShow = false
//                self.topViewController()?.dismiss(animated: true, completion: nil)
                self.topViewController()?.dismiss(animated: false, completion: nil)
               
            } label: {
                HStack{
                    Text("发消息").foregroundColor(.white).font(.system(size: 17, weight: .medium, design: .default))
                }.frame(width: 200, height: 50, alignment: .center).background(Capsule().fill(Color.red))
               
            }.buttonStyle(PlainButtonStyle())
            
            Button {
                isShow = false
                self.topViewController()?.dismiss(animated: true, completion: nil)
            } label: {
                Text("继续探索").foregroundColor(.gray).font(.system(size: 17, weight: .medium, design: .default)).frame(maxWidth:.infinity,maxHeight: .infinity)
            }.frame(width: 200, height: 50, alignment: .center).contentShape(Rectangle()).buttonStyle(PlainButtonStyle())
            Spacer()

        }.frame(maxWidth:.infinity).background( Rectangle().fill(Color.gray.opacity(0.3)).blur(radius: 20)).onAppear {
            isShowAnimation = true
        }
     }
    }
}

struct LikeEachOtherView_Previews: PreviewProvider {
    static var previews: some View {
        LikeEachOtherView(isShow: .constant(true),avatar: "",likeUserAvatar: "",toUserId: 0)
    }
}

struct RecommandList_Previews: PreviewProvider {
    static var previews: some View {
        RecommandList()
    }
}
