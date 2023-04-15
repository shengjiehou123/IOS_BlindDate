//
//  DynamicCircle.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/15.
//

import SwiftUI
import SDWebImageSwiftUI
import HandyJSON
import JFHeroBrowser
import Combine

class CircleModel:HandyJSON,Identifiable,ObservableObject{
    var id : Int = 0
    var uid : Int = 0
    var content : String = ""
    var images : String = ""
    var _images : String{
       let arr = images.components(separatedBy: ",")
        var imageUrls : [String] = []
        for item in arr{
            if item.count > 0{
                let imageUrl = Consts.shared.imageHost + item
                imageUrls.append(imageUrl)
            }
        }
        return imageUrls.joined(separator: ",")
    }
    var userInfo : CircleUserInfo = CircleUserInfo()
    var likeCount : Int = 0
    var likeInfoList : [CircleLikeUserInfo] = []
    var commentCount : Int = 0
    var createAt : String = ""
    required init() {
        
    }
}

class CircleUserInfo:HandyJSON{
    var avatar : String = ""
    var _avatar : String{
        return Consts.shared.imageHost + avatar
    }
    var nickName : String = ""
    var birthday : Double = 0
    var workCityName : String = ""
    var job : String = ""
    required init() {
        
    }
}

class CircleLikeUserInfo:HandyJSON{
    var id : Int = 0
    var circleId : Int = 0
    var likeCircleUid : Int = 0
    var likeCircle : Bool = false
    required init() {
        
    }
}

class DynamicManager : BaseModel{
    
    func requestReportCircle(circleId:Int,type:String){
        let param = ["circleId":circleId,"type":type] as [String : Any]
        self.showLoading = true
        self.loadingBgColor = .clear
        NW.request(urlStr: "report/circle",method: .post,parameters: param) { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = "感谢您的反馈,我们会快速处理"
        } failedHandler: { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }
    }
}

struct DynamicCircleView: View {
    @State var listData : [CircleModel] = []
    @State var page : Int = 1
    @State var pageLimit : Int = 10
    @State var isPresentCreateCircleView : Bool = false
    @State var showComment : Bool = false
    @State var selectCircleModel : CircleModel = CircleModel()
    @State var isFirst : Bool = true
    @StateObject var dynamicManager : DynamicManager = DynamicManager()
    var body: some View {
     
        
         RefreshableScrollView(refreshing: $dynamicManager.pullDown, pullDown: {
             requestCircleList(state: .pullDown)
         }, footerRefreshing: $dynamicManager.footerRefreshing, loadMore: $dynamicManager.loadMore) {
             requestCircleList(state: .pullUp)
         } content: {
             ForEach(listData,id:\.id){ model in
                 CircleRow(model:model,tapCircleHandle:{show in
                     showComment = true
                     selectCircleModel = model
                 }).environmentObject(dynamicManager)
             }
         }.navigationBarTitleDisplayMode(.inline).modifier(LoadingView(isShowing: $dynamicManager.showLoading, bgColor: $dynamicManager.loadingBgColor)).onAppear {
             NotificationCenter.default.addObserver(forName: .init(rawValue: kNotiCreateCircle), object: nil, queue: .main) { _ in
                 isPresentCreateCircleView = true
             }
             if !isFirst {
                 return
             }
             isFirst = false
             requestCircleList(state: .normal)
         }.preferredColorScheme(.light).alertB(isPresented: $isPresentCreateCircleView) {
             CreateDynamicCircleView(show: $isPresentCreateCircleView) {
                 dynamicManager.pullDown = true
                 requestCircleList(state: .pullDown)
             }
         }.toast(isShow: $dynamicManager.showToast, msg: dynamicManager.toastMsg)
            .alertB(isPresented: $showComment) {
                CommentListView(show:$showComment).environmentObject(selectCircleModel)
            }

        
    
            
 
  }
    
    
    func requestCircleList(state:RefreshState){
        if state == .normal {
            dynamicManager.loadingBgColor = .white
            dynamicManager.showLoading = true
            page = 1
        }else if state == .pullDown{
            page = 1
        }else if state == .pullUp{
            page += 1
        }
        let params = ["page":page,"pageLimit":pageLimit]
        NW.request(urlStr: "circle/list", method: .post, parameters: params) { response in
            dynamicManager.showLoading = false
            dynamicManager.pullDown = false
            dynamicManager.footerRefreshing = false
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            if state == .normal || state == .pullDown {
                listData.removeAll()
            }
            if list.count < pageLimit {
                dynamicManager.loadMore = false
            }else{
                dynamicManager.loadMore = true
            }
            var tempArr : [CircleModel] = []
            for item in list {
                guard let model = CircleModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                model.likeCount = model.likeInfoList.count
                tempArr.append(model)
            }
            listData.append(contentsOf: tempArr)
            
        } failedHandler: { response in
            dynamicManager.showLoading = false
            dynamicManager.pullDown = false
            dynamicManager.footerRefreshing = false
            dynamicManager.loadMore = true
            dynamicManager.showToast = true
            dynamicManager.toastMsg = response.message
            
        }

    }
}

struct CircleRow:View{
    var model : CircleModel
    var tapCircleHandle : (_ show:Bool) ->Void
    @EnvironmentObject var dynamicManager : DynamicManager
    @State var showComment : Bool = false
    @State var images: [String] = []
    @State var imageSize : CGSize = CGSize(width: 100, height: 100)
    @State var rowsCount : Int = 0
    @State var likeCircleMap : [Int:CircleLikeUserInfo] = [:]
    @State var push : Bool = false
    @State var pushUid : Int = 0
    @State var showReport : Bool = false
    @State var showActionReport : Bool = false
    var body: some View{
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                NavigationLink{
                    UserIntroduceView(uid: model.uid)
                } label: {
                    WebImage(url: URL(string:model.userInfo._avatar)).resizable().aspectRatio( contentMode: .fill).frame(width: 40, height: 40, alignment: .center).background(Color.red).clipShape(Circle())
                }
               
                VStack(alignment: .leading, spacing: 5){
                    Text(model.userInfo.nickName).font(.system(size: 13,weight:.medium))
                    HStack(alignment: .center, spacing: 3){
                        Text("\(Date.init(timeIntervalSince1970: model.userInfo.birthday).getAge())岁").font(.system(size: 13)).foregroundColor(.gray)
                        Text(model.userInfo.workCityName).font(.system(size: 13)).foregroundColor(.gray)
                        Text(model.userInfo.job).font(.system(size: 13)).foregroundColor(.gray)
                    }
                }
                Spacer()
            }.frame(maxWidth:.infinity).padding(.leading,15)
            
            HStack(alignment: .center, spacing: 0){
                Spacer().frame(width:50)
                Text(model.content).lineSpacing(10)
                Spacer()
            }.frame(maxWidth:.infinity).padding(.leading,15)
            if images.count > 0 {
                VStack(alignment: .leading, spacing: 5){
                    ForEach(0..<rowsCount,id:\.self){ i in
                        HStack(alignment: .center,spacing: 5){
                            ForEach(0..<3,id:\.self){ j in
                                let index = getIndex(i: i, j: j)
                                if index < images.count {
                                    let urlStr = "\(images[index])".urlEncoded()
                                    let url = URL(string: urlStr)
                                    WebImage(url:url).onSuccess(perform: { image, data, cacheType in
                                        imageSize = image.size
                                    }).resizable().aspectRatio(contentMode: .fill)
                                        .frame(width:images.count == 1 ? getImageWidth() : 100,height: images.count == 1 ? getImageHeight() : 100,alignment: .center).background(Color.gray).clipShape(RoundedRectangle(cornerRadius: 10)).contentShape(Rectangle()).onTapGesture {
                                            var list: [HeroBrowserViewModule] = []
                                            for imageUrlStr in images {
                                                list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: imageUrlStr, originImgUrl: imageUrlStr))
                                            }
                                            myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                                        }
                                }else{
                                    EmptyView().frame(width: 0, height: 0, alignment: .leading)
                                }
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 65, bottom: 0, trailing: 10))
            
            }
            
            HStack(alignment:.center,spacing:35){
                Image("more").renderingMode(.template).resizable().aspectRatio(contentMode: .fill).frame(width:20,height:10,alignment: .leading).foregroundColor(.gray).padding(.leading,65).contentShape(Rectangle()).onTapGesture {
                    showReport = true
                }
                Spacer()
                HStack(alignment: .center, spacing: 8) {
                    Image("like").renderingMode(.template).resizable().aspectRatio(contentMode: .fill).frame(width: 24, height: 24, alignment: .center).foregroundColor( likeCircleMap[UserCenter.shared.userInfoModel?.id ?? 0] != nil ? Color.red : Color.gray)
                    Text("\(model.likeCount)").foregroundColor(.colorWithHexString(hex: "#999999"))
                }.onTapGesture {
                    let item = likeCircleMap[UserCenter.shared.userInfoModel?.id ?? 0]
                    requestCreateLikeCircle(likeCircle: (item != nil) ? false : true)
                }
                HStack(alignment: .center, spacing: 8) {
                    Image("comment").resizable().renderingMode(.template).aspectRatio(contentMode: .fill).frame(width: 24, height: 24, alignment: .center).foregroundColor(Color.gray)
                    Text("\(model.commentCount)").foregroundColor(.colorWithHexString(hex: "#999999"))
                }.onTapGesture {
//                    showComment = true
                    tapCircleHandle(true)
                }
                
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            
           

        }.padding(.bottom,20)
            .customActionSheet(isPresented: $showReport, actions: {
            Button {
                showReport = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    showActionReport = true
                })
              
            } label: {
                Text("举报帖子").foregroundColor(.colorWithHexString(hex: "333333")).frame(maxWidth:.infinity,maxHeight:50).contentShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())

            LineHorizontalView()
            Button {
                showReport = false
            } label: {
                Text("取消").foregroundColor(.colorWithHexString(hex: "333333")).frame(maxWidth:.infinity,maxHeight:50).padding(.bottom,kSafeBottom).contentShape(Rectangle())
              
            }.buttonStyle(PlainButtonStyle())

            }).customActionSheet(isPresented: $showActionReport, actions: {
                let repostTypes = ["广告营销","色情低俗","诈骗","恶意骚扰、不文明语言","刷屏","其他","取消"]
                VStack(spacing:0){
                    ForEach(0..<repostTypes.count,id:\.self){ index in
                        let resportType = repostTypes[index]
                        Button {
                            showActionReport = false
                            if resportType == "其他"{
                                
                            }else if resportType != "取消"{
                                dynamicManager.requestReportCircle(circleId: model.id, type: resportType)
                            }
                        } label: {
                            Text(resportType).foregroundColor(.colorWithHexString(hex: "333333")).frame(maxWidth:.infinity, maxHeight:50).contentShape(Rectangle()).padding(.bottom,index == repostTypes.count - 1 ? kSafeBottom : 0)
                           
                        }.buttonStyle(PlainButtonStyle())
                        LineHorizontalView()
                    }
                }
                
            })
        
        .alertB(isPresented: $showComment) {
            CommentListView(show:$showComment).environmentObject(model)
        }
        
        .onAppear {
            if !model._images.isEmpty{
                if model._images.contains(",") {
                    images =  model._images.components(separatedBy: ",")
                }else{
                    images = [model._images]
                }
                rowsCount = getRow(total: images.count)
            }else{
                images = []
                rowsCount = 0
            }
            for item in model.likeInfoList {
                likeCircleMap[item.likeCircleUid] = item
            }
            
          
        }
    }
    
    func requestCreateLikeCircle(likeCircle:Bool){
        let params = ["circleId":model.id,"uid":model.uid,"likeCircleUid":UserCenter.shared.userInfoModel?.id ?? 0,"likeCircle":likeCircle] as [String : Any]
        
        NW.request(urlStr: "like/circle", method: .post, parameters: params) { response in
            if likeCircle {
                let userInfo = CircleLikeUserInfo()
                userInfo.circleId = model.id
                userInfo.likeCircleUid = UserCenter.shared.userInfoModel?.id ?? 0
                likeCircleMap[UserCenter.shared.userInfoModel?.id ?? 0] = userInfo
                model.likeCount += 1
            }else{
                likeCircleMap.removeValue(forKey:  UserCenter.shared.userInfoModel?.id ?? 0)
                model.likeCount -= 1
            }
        } failedHandler: { response in
            
        }
    }
    
    
    
    func getImageWidth() ->CGFloat{
        if imageSize.width > imageSize.height {
            return 230
        }
        return 150
    }
    
    func getImageHeight() -> CGFloat{
        if imageSize.width > imageSize.height {
            return 230 * imageSize.height / imageSize.width
        }
        let height = 150 * imageSize.height / imageSize.width
        if height > 250 {
            return 250
        }
        return height
    }

    
    func getRow(total:Int) ->Int{
        return (total-1) / 3 + 1
    }
    
    func getIndex(i:Int,j:Int) ->Int{
        let index = i*3 + j
        return index
    }
}

class ObserverTapModel:ObservableObject,Identifiable{
    @Published var sectionTap : Bool = false
    @Published var commentId : Int = 0
    @Published var nickName : String = ""
    @Published var atUid : Int = 0
    @Published var atSecondaryCommentId : Int = 0
    @Published var sendCommentMsgSuc : Bool = false
    @Published var sendSecondaryCommentMsgSuc : Bool = false
}

struct CommentListView:View{
    @Binding var show : Bool
    @EnvironmentObject var circleModel : CircleModel
//    @StateObject var obModel : ObserVedCommentModel = ObserVedCommentModel()
    @State var titles : [CommentModel] = []
    @StateObject var observerTapModel : ObserverTapModel = ObserverTapModel()
    @State var showSecondaryList : Bool = false
    @State var showAnimation : Bool = false
    @State var comment : String = ""
    @StateObject var dynamicManager : MyComputedProperty = MyComputedProperty()
    @State var page : Int = 1
    var body: some View{
        if show{
    ZStack(alignment: .bottomLeading){
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(Color.black.opacity(0.3))
        VStack(alignment: .leading, spacing: 0){
            HStack(alignment: .center, spacing: 0){
                Text(circleModel.commentCount > 0 ? "评论\(circleModel.commentCount)" : "评论").font(.system(size: 18, weight: .medium, design: .default))
                Spacer()
                Button {
                    showAnimation = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.topViewController()?.dismiss(animated: false, completion: nil)
//                        tabBarVc?.tabBar.isHidden = false
                        show = false
                    }
                } label: {
                    HStack{
                        Image("close").resizable().renderingMode(.original).aspectRatio( contentMode: .fill).frame(width: 24, height: 24, alignment: .center)
                    }.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                }

                
            }.padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 0)).frame(height:50)
        
            ScrollViewReader { reader in
            RefreshableScrollView(refreshing: $dynamicManager.pullDown, pullDown: nil, footerRefreshing: $dynamicManager.footerRefreshing, loadMore: $dynamicManager.loadMore) {
                requestCommentList(state: .pullUp)
            } content: {
               
                ForEach(titles,id:\.id){ model in
                    Section(header: CommentSection(model:model).environmentObject(observerTapModel).id(model.id)) {
                        SecondaryRowList(model: model) { show in
                            show ? reader.scrollTo(model.list.first?.id) : reader.scrollTo(model.id)
                        }.environmentObject(observerTapModel)
                        
                    }.onChange(of: observerTapModel.sendCommentMsgSuc) { newValue in
                        if newValue {
                            observerTapModel.sendCommentMsgSuc = false
                            reader.scrollTo(titles[0].id, anchor: .center)
                        }
                    }
                }
              
             }.padding(.bottom,65 + kSafeBottom)
            }

            
//        ScrollView(.vertical,showsIndicators: false){
//            ScrollViewReader { reader in
//                LazyVStack(alignment: .leading, spacing: 10){
//
//
//
//                }
//            }
//
//        }.padding(.bottom,65 + kSafeBottom)
        
           
        }.background((RoundedCorner(corners: [.topLeft,.topRight], radius: 10).fill(Color.white))).frame(maxWidth:.infinity,maxHeight: screenHeight * 0.8).offset(y:showAnimation ? 0: screenHeight * 0.8 + 20).animation(.linear(duration: 0.25), value: showAnimation).onAppear {
            showAnimation = true
         }
            
        }.edgesIgnoringSafeArea(.all).onAppear {
            requestCommentList(state: .normal)
       }
        if observerTapModel.sectionTap {
            Rectangle().fill(Color.black.opacity(0.3)).onTapGesture {
                hidenKeyBoard()
                observerTapModel.sectionTap = false
            }.edgesIgnoringSafeArea(.top)
        }
       
        CommentSendMsgView(circleId: $circleModel.id,totalCommentListCount:$circleModel.commentCount,sendCommentSucHandle: {
            
            requestCommentList(state: .normal)
        }).environmentObject(observerTapModel)
        
    }.ignoresSafeArea(edges: .bottom).onTapGesture {
        observerTapModel.sectionTap = false
    }
     }
    }
    func requestCommentList(state:RefreshState){
        if state == .pullUp {
            page += 1
        }else{
            page = 1
        }
        if state == .normal {
            dynamicManager.showLoading  = true
            dynamicManager.loadingBgColor = .white
        }
        let params = ["circleId":circleModel.id,"page":page,"pageLimit":10]
        NW.request(urlStr: "comment/list",method: .post,parameters: params) { response in
            dynamicManager.showLoading = false
            dynamicManager.pullDown = false
            dynamicManager.footerRefreshing = false
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            if state == .normal || state == .pullDown {
                titles.removeAll()
            }
            if list.count < 10 {
                dynamicManager.loadMore = false
            }else{
                dynamicManager.loadMore = true
            }
            for item in list {
                guard let model = CommentModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                titles.append(model)
            }
            guard let total = response.data["total"] as? Int else{
                circleModel.commentCount = 0
                return
            }
            circleModel.commentCount = total
        } failedHandler: { response in
            dynamicManager.showLoading = false
            dynamicManager.pullDown = false
            dynamicManager.loadMore = true
            dynamicManager.footerRefreshing = false
        }
    }
    
    
    
    
}

//MARK: 发送评论
struct CommentSendMsgView:View{
    @Binding var circleId : Int
    @Binding var totalCommentListCount : Int
    @State var comment : String = ""
    var sendCommentSucHandle : () ->Void
    @State var keyBoardShow : Bool = false
    @State var introSepectTextField : UITextField? = nil
    @EnvironmentObject var tapModel : ObserverTapModel
    var body: some View{
        HStack(alignment: .center, spacing: 0) {
            TextField(tapModel.nickName.count > 0 ? "回复\(tapModel.nickName)" : "评论...", text: $comment,onCommit: {
                tapModel.sectionTap = false
                tapModel.nickName = ""
                if !comment.isEmpty {
                    if tapModel.commentId > 0 {
                        requestCreateSecondaryComment()
                    }else{
                        requestCreateComment()
                    }
                }
            }).frame(maxWidth:.infinity,maxHeight:50).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)).background(Capsule().fill(Color.colorWithHexString(hex: "#F3F3F3"))).onChange(of: comment) { newValue in
                comment = comment.trimmingCharacters(in: .whitespaces)
            }.onReceive(Publishers.keyboardHeight) {
                let keyboardHeight = $0
                keyBoardShow  = keyboardHeight > 0 ? true : false
            }.introspectTextField { textField in
               introSepectTextField = textField
            }.onReceive(tapModel.$sectionTap) { _ in
                if tapModel.sectionTap {
                    introSepectTextField?.becomeFirstResponder()
                }else{
                    introSepectTextField?.resignFirstResponder()
                }
            }
        }.padding(EdgeInsets(top: 10, leading: 20, bottom: keyBoardShow ? 5 : kSafeBottom, trailing: 20)).introspectTextField { textfield in
            textfield.returnKeyType = .send
        }.background(Color.white).keyboardAdaptive()
    }
    
    func requestCreateComment(){
        let params = ["circleId":circleId,"comment":comment] as [String : Any]
        NW.request(urlStr: "create/comment", method: .post, parameters: params) { response in
            comment = ""
            tapModel.sendCommentMsgSuc = true
            sendCommentSucHandle()
        } failedHandler: { response in
            
        }

    }
    
    func requestCreateSecondaryComment(){
        let params = ["commentId":tapModel.commentId,"atUid":tapModel.atUid,"atSecondaryCommentId":tapModel.atSecondaryCommentId,"comment":comment] as [String : Any]
        NW.request(urlStr: "create/secondary/comment", method: .post, parameters: params) { response in
            tapModel.sendSecondaryCommentMsgSuc = true
            tapModel.atUid = 0
            tapModel.atSecondaryCommentId = 0
//            tapModel.commentId = 0
            tapModel.nickName = ""
            comment = ""
            totalCommentListCount += 1
//            sendCommentSucHandle()
        } failedHandler: { response in
            
        }

    }
}

struct SecondaryRowList:View{
   
    @State var show:Bool = true
    @State var page : Int = 1
    @ObservedObject var model : CommentModel
    var listChangeHandle : (_ show:Bool) ->Void
    @EnvironmentObject var tapModel : ObserverTapModel
    private let pageLimit = 5
    var body: some View{
        
        if show {
            ForEach(model.list,id:\.id){ secondaryCommentModel in
                SecondaryCommentRow(model: secondaryCommentModel).environmentObject(tapModel).id(secondaryCommentModel.id)
            }.onChange(of: model.list) { _ in
                listChangeHandle(show)
            }.onReceive(tapModel.$sendSecondaryCommentMsgSuc) { newValue in
                log.info("model.id\(model.id) tapModel.commentId\(tapModel.commentId) tapModel.sendSecondaryCommentMsgSuc \(newValue)")
                if model.id == tapModel.commentId && newValue{
                    tapModel.sendSecondaryCommentMsgSuc = false
                    requestSecondaryCommentList(commentId: tapModel.commentId, state: .normal)
                }
            }
        }
       
        
            
            if model.secondaryCount > 0 || model.list.count > 0{
             VStack(alignment: .leading, spacing: 0) {
                if model.list.count < model.secondaryCount || !show{
                    HStack{
                        Button {
                            if(model.secondaryCount > 0 && model.secondaryCount == model.list.count){
                                show = true
                                return
                            }
                            requestSecondaryCommentList(commentId: model.id, state: .pullUp)
                        } label: {
                            HStack(alignment: .center, spacing: 0) {
                                Spacer().frame(width:60)
                                Text("–– 展开\(!show ? model.list.count : model.secondaryCount-model.list.count)条回复").font(.system(size: 13, weight: .medium, design: .default))
                                Image("pull_down_indicator").resizable().renderingMode(.template).foregroundColor(.black).aspectRatio(contentMode: .fill)
                                    .frame(width: 14, height: 14, alignment: .center)
                                Spacer().frame(width:45)
                            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        }.buttonStyle(PlainButtonStyle()).foregroundColor(.black).frame(alignment:.leading)
                        Spacer()
                    }
                    
                    
                }else{
                    HStack{
                        
                        Button {
                            show = false
                            listChangeHandle(show)
                        } label: {
                            HStack(alignment: .center, spacing: 0) {
                                Spacer().frame(width:60)
                                Text("–– 收起").font(.system(size: 13, weight: .medium, design: .default))
                                Image("pull_down_indicator").resizable().renderingMode(.template).foregroundColor(.black).aspectRatio(contentMode: .fill)
                                    .frame(width: 14, height: 14, alignment: .center)
                            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        }.buttonStyle(PlainButtonStyle()).foregroundColor(.black)
                        Spacer()
                    }
                    
                }
                }.frame(maxWidth:.infinity)
         }
        
    }
    
    func requestSecondaryCommentList(commentId:Int,state:RefreshState){
        var page = 1
        if model.list.count > 0 {
            page =  model.list.count / pageLimit + 1
        }
        self.page = page
       
        let params = ["commentId":commentId,"page":self.page,"pageLimit":pageLimit]
        NW.request(urlStr: "secondary/comment/list", method: .post, parameters: params) { response in
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            guard let totalCount = response.data["total"] as? Int else{
                return
            }
            model.secondaryCount = totalCount
            var mapIds  : [Int:Int] = [:]
            for (index,item) in model.list.enumerated(){
                mapIds[item.id] = index + 1
            }
            for item in list {
                guard let secondaryCommentModel = SecondaryCommentModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                
                let existItem = mapIds[secondaryCommentModel.id] ?? 0
                if existItem == 0{
                    if let index = mapIds[secondaryCommentModel.atSecondaryCommentId]{
                        model.list.insert(secondaryCommentModel, at: index)
                    }else{
                        if tapModel.commentId > 0 {
                            model.list.insert(secondaryCommentModel, at: 0)
                            tapModel.commentId = 0
                        }else{
                            model.list.append(secondaryCommentModel)
                        }
                      
                    }
                   
                }
               
                
//                if !model.list.contains(where: { $0.id == secondaryCommentModel.id}) &&  secondaryCommentModel.atSecondaryCommentId == 0 {
//                    model.list.append(secondaryCommentModel)
//                }else if !model.list.contains(where: { $0.id == secondaryCommentModel.id}) && model.list.contains(where: {$0.id == secondaryCommentModel.atSecondaryCommentId}){
//
//
//                }
               
            }
        } failedHandler: { response in
            
        }

    }
}

struct CommentSection:View{
    var model : CommentModel
    @EnvironmentObject var tapModel : ObserverTapModel
    @State var push : Bool = false
    var body: some View{
        Button {
            tapModel.sectionTap = true
            tapModel.commentId = model.id
            tapModel.atUid = 0
            tapModel.atSecondaryCommentId = 0
            tapModel.nickName = model.userInfo.nickName
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top, spacing: 5){
                    Spacer().frame(width:20)
                    NavigationLink{
                        UserIntroduceView(uid: model.uid)
                    } label: {
                        WebImage(url: URL(string: model.userInfo._avatar)).resizable().aspectRatio(contentMode: .fill).background(Color.gray).clipShape(Circle()).frame(width: 30, height: 30, alignment: .center)
                    }
                   
                    VStack(alignment: .leading, spacing: 3){
                        Text(model.userInfo.nickName).font(.system(size: 13)).foregroundColor(.colorWithHexString(hex: "#999999"))
                        Text(model.comment).font(.system(size: 15)).lineSpacing(5)
                    }
                    Spacer()
                }
                HStack(alignment: .center, spacing: 5){
                    Spacer().frame(width:55)
                    Text(model.createAt).font(.system(size: 12)).foregroundColor(.colorWithHexString(hex: "#999999"))
                    Text("回复").font(.system(size: 12, weight: .medium, design: .default)).foregroundColor(.colorWithHexString(hex: "#999999"))
                    Spacer()
                }
                

            }.contentShape(Rectangle()).id(model.id).padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 5))
        }.buttonStyle(HighlightButtonStyle()).foregroundColor(.black)

          
        
    }
    
}

struct SecondaryCommentRow:View{
    var model : SecondaryCommentModel
    @EnvironmentObject var tapObserModel : ObserverTapModel
    var body: some View{
        Button {
            tapObserModel.commentId = model.commentId
            tapObserModel.atUid = model.uid
            tapObserModel.atSecondaryCommentId = model.id
            tapObserModel.nickName = model.uidInfo.nickName
            tapObserModel.sectionTap = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 5){
                    Spacer().frame(width:55)
                    NavigationLink {
                        UserIntroduceView(uid:model.uid)
                    } label: {
                        WebImage(url: URL(string: model.uidInfo._avatar)).resizable().aspectRatio(contentMode: .fill).background(Color.gray).clipShape(Circle()).frame(width: 20, height: 20, alignment: .center)
                    }

                    Text(model.atUid > 0 ? "\(model.uidInfo.nickName)►\(model.atUidInfo.nickName)" : "\(model.uidInfo.nickName)").font(.system(size: 13)).foregroundColor(.colorWithHexString(hex: "#999999"))
                    Spacer()
                }
                Spacer().frame(height:3)
                HStack(alignment: .center, spacing: 0) {
                    Spacer().frame(width:85)
                    Text(model.comment).font(.system(size: 15)).lineSpacing(5)
                    Spacer()
                }
                Spacer().frame(height:5)
                HStack(alignment: .center, spacing: 5){
                    Spacer().frame(width:80)
                    Text(model.createAt).font(.system(size: 12)).foregroundColor(.gray)
                    Text("回复").font(.system(size: 12, weight: .medium, design: .default)).foregroundColor(.colorWithHexString(hex: "#999999"))
                    Spacer()
                }
            }.contentShape(Rectangle()).padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 5))
        }.buttonStyle(HighlightButtonStyle()).foregroundColor(.black)

          
        
    }
}

class CommentModel:HandyJSON,ObservableObject,Identifiable,Equatable{
    static func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id : Int = 0
    var circleId : Int = 0
    var uid : Int = 0
    var comment: String = ""
    var createAt : String = ""
    var secondaryCount :Int = 0
    var userInfo : CircleUserInfo = CircleUserInfo()
    @Published var list : [SecondaryCommentModel] = []
    @Published var total : Int = 0
    required init() {
        
    }
}

class SecondaryCommentModel:HandyJSON,Identifiable,Equatable{
    static func == (lhs: SecondaryCommentModel, rhs: SecondaryCommentModel) -> Bool{
        return lhs.id == rhs.id
    }
    var id :Int = 0
    var commentId :Int = 0
    var uid : Int = 0
    var atUid : Int = 0
    var comment : String = ""
    var createAt : String = ""
    var updateAt : String = ""
    var atSecondaryCommentId : Int = 0
    var uidInfo:CircleUserInfo = CircleUserInfo()
    var atUidInfo:CircleUserInfo = CircleUserInfo()
    required init() {
        
    }
}

//struct CommentListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentListView(show: .constant(true),circleId: 1)
//
//    }
//}

//struct DynamicCircle_Previews: PreviewProvider {
//    static var previews: some View {
//        DynamicCircleView()
//    }
//}
