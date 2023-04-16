//
//  RecommandList.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI
import SDWebImageSwiftUI
import JFHeroBrowser


class RecommandData:BaseModel{
    @Published var listData : [ReCommandModel] = []
    @Published var displayListData : [ReCommandModel] = []
    @Published var page : Int = 1
    
    func requestRecommandList(state:RefreshState){
        if state == .normal{
            self.showLoading = true
            self.loadingBgColor = .white
        }
        if state != .pullUp{
            self.page = 1
        }
        let param = ["page":self.page,"pageLimit":6]
        NW.request(urlStr: "recommended/list", method: .post, parameters: param) { response in
            self.showLoading = false
            if state == .normal || state == .pullDown || state == .refresh {
                self.displayListData.removeAll()
            }
            
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            
            self.page += 1

            for item in list {
                guard let recommandModel = ReCommandModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
//                if state == .normal || state == .refresh{
                    self.displayListData.append(recommandModel)
//                }else{
//                    self.displayListData.insert(recommandModel, at: 0)
//                }
            }
          
//            self.displayListData = self.listData
        } failedHandler: { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }

    }
    
    func getIndex(model:ReCommandModel) ->Int{
        let index = displayListData.firstIndex(where: { currentModel in
             return model.id == currentModel.id
        }) ?? 0
                
        return index
      
    }
}

struct RecommandList: View {
    @StateObject var recommnadData : RecommandData = RecommandData()
    @State var isFirst : Bool = true
    var body: some View {   
        ZStack(alignment: .top){
             let listData = recommnadData.displayListData
                ForEach(listData.reversed(),id:\.id){ model in
                    ScrollCardView(recommandModel: model).environmentObject(recommnadData)
                }
            
            
        }.navigationBarTitleDisplayMode(.inline).padding(.top,30).lightWaveView(isShow: $recommnadData.showLoading)
            .toast(isShow: $recommnadData.showToast, msg: recommnadData.toastMsg).onAppear {
                if !isFirst {
                    return
                }
                isFirst = false
               recommnadData.requestRecommandList(state: .normal)
       
     }
            
        
    }
    
    
}

struct ScrollCardView:View{
    var recommandModel : ReCommandModel
    @EnvironmentObject  var recommnadData : RecommandData
    @GestureState var offset : CGFloat = 0;
    @State var offsetX : CGFloat = 0;
    @GestureState var isDragging : Bool = false
    @State var endSwipe : Bool = false
    @State var likeUseAvatar : String = ""
    @State var showLikeEachOther : Bool = false
    @State var showLeftText : Bool = false
    @State var showRightText : Bool = false
    @State var profileContent : [String] = []
//    @State var topOffset : Int = 0
    
    var body: some View{

        let index = recommnadData.getIndex(model: recommandModel)
        let topOffset = (index <= 2 ? index  : 2 ) * 10
        let dragGesture = DragGesture()
                .updating($offset) { value, gestureState, transaction in
                    gestureState = value.translation.width
                }
                .updating($isDragging) { value, gestureState, transaction in
                    gestureState = true
                }
    ZStack(alignment: .top) {
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                ForEach(0...4,id:\.self){ index in
                    if index == 0{
                        CardView(recommandModel:recommandModel)
                    }
                  
                    if index == 1{
                        HomePageAboutUsView(title: "关于我",content: recommandModel.myTag.count > 0 ? (recommandModel.aboutMeDesc + "\n" + recommandModel.myTag) : recommandModel.aboutMeDesc,userPhotos: recommandModel.userPhotos)
                    }
                    
                    if index == 2{
                        MyProfileView(title: "基本资料", contents: profileContent)
                    }
                   
                    if index == 3{
                        HomePageAboutUsView(title: "希望对方",content: recommandModel.likePersonTag,userPhotos: [])
                    }
                  
                    if !recommandModel.loveGoalsDesc.isEmpty && index == 4 {
                        HomePageAboutUsView(title: "恋爱目标",content: recommandModel.loveGoalsDesc,userPhotos: [])
                    }
                }
               
                
            }.introspectScrollView(customize: { scrollView in
                scrollView.bounces = false
            }).onAppear{
                profileContent.append("\(recommandModel.height)cm")
                if !recommandModel.school.isEmpty{
                    profileContent.append("\(recommandModel.school)")
                }
                
                if !recommandModel.educationTypeDesc.isEmpty{
                    profileContent.append("\(recommandModel.educationTypeDesc)")
                }
                
                if !recommandModel.job.isEmpty{
                    profileContent.append("\(recommandModel.job)")
                }
                
                if !recommandModel.yearIncomeDesc.isEmpty{
                    profileContent.append("年薪\(recommandModel.yearIncomeDesc)")
                }
                
                if !recommandModel.homeTownCityName.isEmpty{
                    if recommandModel.homeTownProvinceName != recommandModel.homeTownCityName{
                        profileContent.append("家乡\(recommandModel.homeTownProvinceName)\(recommandModel.homeTownCityName)")
                    }else{
                        profileContent.append("家乡\(recommandModel.homeTownProvinceName)")
                    }
                }
                
                if !recommandModel.workCityName.isEmpty{
                    if recommandModel.workProvinceName != recommandModel.workCityName{
                        profileContent.append("现居地\(recommandModel.workProvinceName)\(recommandModel.workCityName)")
                    }else{
                        profileContent.append("现居地\(recommandModel.workProvinceName)")
                    }
                }
                
            }
            
        }.navigationViewStyle(.stack).clipShape(RoundedRectangle(cornerRadius: 10)).background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(color: Color.colorWithHexString(hex: "#E3E3E3").opacity(0.6), radius: 2, x: 0, y: 2)).padding(EdgeInsets(top: 0, leading: 10, bottom: CGFloat(topOffset) + 10, trailing: 10)).offset(y:-CGFloat(topOffset)).frame(width:screenWidth  - CGFloat(topOffset))
        if showLeftText {
            HStack(alignment: .center, spacing: 0) {
                Text("还不错").foregroundColor(Color.red).font(.system(size: 40, weight: .bold, design: .default)).padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)).background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.red,style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, miterLimit: 0)))
                Spacer()
            }.offset(x: 30, y: 10).rotationEffect(.init(degrees: -15),anchor:.bottom)
        }
        
        if showRightText {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Text("不合适").foregroundColor(Color.blue).font(.system(size: 40, weight: .bold, design: .default)).padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)).background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.blue,style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, miterLimit: 0)))
            }.offset(x: -30, y: 10).rotationEffect(.init(degrees: 15),anchor:.bottom)
        }
    }.padding(.top,0).offset(x:offsetX)
            .rotationEffect(.init(degrees: getRotation(angle: 8)),anchor: .bottom).contentShape(Rectangle().trim(from: 0, to: endSwipe ? 0 : 1))
            .alertB(isPresented: $showLikeEachOther, builder: {
                LikeEachOtherView(isShow: $showLikeEachOther,avatar: UserCenter.shared.userInfoModel?._avatar ?? "",likeUserAvatar: recommandModel._avatar,toUserId: recommandModel.id)
            }).onChange(of: offset, perform: { newValue in
                if isDragging{
                    offsetX = newValue
                    let checkingStatus = newValue > 0 ? newValue : -newValue
                    if checkingStatus > 15 {
                        if newValue > 0 {
                            //rightswipe
                            //like
                            showLeftText = true
                            showRightText = false
                          
                        }else{
                            //leftswipe
                            showLeftText = false
                            showRightText = true
                        }
                    }else{
                        showLeftText = false
                        showRightText = false
                        offsetX = .zero
                    }
                }else{
                    withAnimation(){
                        let checkingStatus = offsetX > 0 ? offsetX : -offsetX
                        if checkingStatus > 15 {
                            endSwipeAction()
                            offsetX = (offsetX > 0 ? screenWidth: -screenWidth) * 2
                            if newValue > 0 {
                                //rightswipe
                                //like
                                requestLikePerson(toUserId: recommandModel.id, like: true)
                            }else{
                                //leftswipe
                                requestLikePerson(toUserId: recommandModel.id, like: false)
                            }
                        }else{
                            showLeftText = false
                            showRightText = false
                            offsetX = .zero
                        }
                    }
                  
                }
            }).onTapGesture {
                
            }.gesture(dragGesture)
    }
    
    func endSwipeAction(){
        withAnimation(.none) {
            endSwipe = true
            if recommnadData.displayListData.count <= 5{
                recommnadData.requestRecommandList(state: .pullUp)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
           if let _ =  recommnadData.displayListData.first{
               let _ = withAnimation {
                   recommnadData.displayListData.removeFirst()
               }
           }
        }
    }
    
    // 旋转
    func getRotation(angle: Double)-> Double{
        let rotation = (offsetX / (screenWidth - 50)) * angle
        return rotation
    }
    
    func requestLikePerson(toUserId:Int,like:Bool){
        let param = ["toUserId":toUserId,"like":like] as [String : Any]
        NW.request(urlStr: "like/person", method: .post, parameters: param) { response in
            let dic = response.data
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

struct MyProfileView:View{
    var title:String = "基本资料"
    var contents:[String]
    var body: some View{
        HStack(alignment: .top, spacing: 0) {
            Text(title)
                .foregroundColor(.gray)
                .font(.system(size: 15, weight: .medium, design: .default))
            Spacer()
        }.padding(EdgeInsets(top: 20, leading: 10, bottom: 15, trailing: 10))
        FlexibleView(data:contents , spacing: 10, alignment: .leading) { item in
            Text(item).foregroundColor(.black).font(.system(size: 16)).lineLimit(1).padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)).background(Capsule().fill(Color.colorWithHexString(hex: "F3F3F3"))).padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        }.padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 10))
    }
}

struct HomePageAboutUsView:View{
    var title : String
    var content: String
    var userPhotos:[UserPhotoModel]
    var body: some View{
            HStack(alignment: .top, spacing: 0) {
                Text(title)
                    .foregroundColor(.gray)
                    .font(.system(size: 15, weight: .medium, design: .default))
                Spacer()
            }.padding(EdgeInsets(top: 20, leading: 10, bottom: 15, trailing: 10))
           
           HStack{
               Text(content).lineSpacing(10).font(.system(size: 17))
               Spacer()
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
            
            ForEach(userPhotos,id:\.id) { model in
                let index = userPhotos.firstIndex(of: model) ?? 0
                let url = URL.init(string:model._photo)
                Spacer().frame(height:10)
                WebImage(url: url).resizable().interpolation(.high).aspectRatio(contentMode:.fill).frame(width:  screenWidth - 20, height: getPhotoHeight(model: model), alignment: .center)
                    .clipped(antialiased: true).contentShape(Rectangle()).onTapGesture {
                   var list: [HeroBrowserViewModule] = []
                   for i in 0..<userPhotos.count {
                       let photoModel = userPhotos[i]
                       list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: photoModel._photo, originImgUrl: photoModel._photo))
                   }
                   myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                }
               
            }
        
    }
    
    func getPhotoHeight(model:UserPhotoModel) -> CGFloat{
        if model.height == 0{
            return 400
        }
        
        
        return CGFloat((Int(screenWidth) - 20) * model.height / model.width)
    }
}

struct CardView:View{
     var recommandModel : ReCommandModel
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            CardHeaderView(recommandModel:recommandModel)
        }
    }
}

struct CardHeaderView:View{
    var recommandModel : ReCommandModel
    @State var titles : [String] = []
    var body: some View{
        ZStack(alignment: .top) {
            GeometryReader { reader in
                let size = reader.size
                WebImage(url: URL(string: recommandModel._bgImageUrl)).resizable().aspectRatio(contentMode: .fill).frame(width: size.width, height: size.height, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10))
            }
       
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0, content: {
                let avatarUrl = URL(string: recommandModel._avatar)
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
            FlexibleView(
                    data: titles,
                    spacing: 10,
                    alignment: .leading
                  ) { item in
                      BlackColorText(title: item)
                  }
                  .padding(EdgeInsets(top: 20, leading: 10, bottom:20, trailing: 10))
            
        }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)).onAppear {
          
            titles.append("\(recommandModel.height)cm")
            if recommandModel.educationType > 2{
                titles.append(recommandModel.educationTypeDesc)
            }
            if !recommandModel.school.isEmpty {
                titles.append(recommandModel.school)
            }
            
            if !recommandModel.job.isEmpty{
                titles.append(recommandModel.job)
            }
            
//            if recommandModel.yearIncome > 1{
//                titles.append("年薪" + recommandModel.yearIncomeDesc)
//            }
            
        }
    }
      
    }
    
    
}

struct BlackColorText:View{
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
    @ObservedObject var naviCenter : NavigationCenter = NavigationCenter.shared
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
                naviCenter.tableSelectionType = .messageTagType
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    NotificationCenter.default.post(name: .init(rawValue: kNotiChatToUserId), object: toUserId)
                }
               
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

        }.frame(maxWidth:.infinity).background(Color.white).ignoresSafeArea(.container, edges: .all).onAppear {
            isShowAnimation = true
        }
     
    }
  }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView()
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect
        uiView.alpha = 0.6
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
