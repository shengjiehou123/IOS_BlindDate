//
//  MyDynamicPage.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/25.
//

import SwiftUI
import SDWebImageSwiftUI
import JFHeroBrowser

class MyDynamicModel:BaseModel{
    @Published var page : Int = 1
    let pageLimit : Int = 10
    @Published var listData:[CircleModel] = []
    @Published var showCommentList : Bool = false
    @Published var showCommentCircleModel : CircleModel = CircleModel()
    
    override init(){
        super.init()
        requestCircleList(state: .normal)
    }
    
    func requestCircleList(state:RefreshState){
        if state == .normal {
            self.loadingBgColor = .white
            self.showLoading = true
            page = 1
        }else if state == .pullDown{
            page = 1
        }else if state == .pullUp{
            page += 1
        }
        let params = ["page":page,"pageLimit":pageLimit]
        self.loadingBgColor = .white
        NW.request(urlStr: "get/my/circle", method: .post, parameters: params) { response in
            self.showLoading = false
            self.pullDown = false
            self.footerRefreshing = false
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            if state == .normal || state == .pullDown {
                self.listData.removeAll()
            }
            if list.count < self.pageLimit {
                self.loadMore = false
            }else{
                self.loadMore = true
            }
            var tempArr : [CircleModel] = []
            for item in list {
                guard let model = CircleModel.deserialize(from: item, designatedPath: nil) else{
                    continue
                }
                model.likeCount = model.likeInfoList.count
                tempArr.append(model)
            }
            self.listData.append(contentsOf: tempArr)
            
        } failedHandler: { response in
            self.showLoading = false
            self.pullDown = false
            self.footerRefreshing = false
            self.loadMore = true
            self.showToast = true
            self.toastMsg = response.message
            self.notifyUpdate()
        }

    }
    
    func requestCreateLikeCircle(likeCircle:Bool,model:CircleModel, requestHandleCompletion:@escaping (_ likeCircle:Bool) -> Void){
        let params = ["circleId":model.id,"uid":model.uid,"likeCircleUid":UserCenter.shared.userInfoModel?.id ?? 0,"likeCircle":likeCircle] as [String : Any]
        self.showLoading = true
        self.loadingBgColor = .clear
        NW.request(urlStr: "like/circle", method: .post, parameters: params) { response in
           requestHandleCompletion(likeCircle)
            self.showLoading = false
        } failedHandler: { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }
    }
    
    func requestDeleteCircle(circleId:Int){
        let params = ["circleId":circleId]
        self.showLoading = true
        self.loadingBgColor = .clear
        NW.request(urlStr: "delete/circle", method: .post, parameters: params) { response in
            self.showLoading = false
            self.requestCircleList(state: .pullDown)
        } failedHandler: { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }
    }
}

struct MyDynamicPage: View {
    @StateObject var myDynamicModel : MyDynamicModel = MyDynamicModel()
    var body: some View {
        ZStack(alignment: .bottom){
            RefreshableScrollView(refreshing: $myDynamicModel.pullDown, pullDown: {
                myDynamicModel.requestCircleList(state: .pullDown)
            }, footerRefreshing: $myDynamicModel.footerRefreshing, loadMore: $myDynamicModel.loadMore) {
                myDynamicModel.requestCircleList(state: .pullUp)
            } content: {
                ForEach(myDynamicModel.listData,id:\.id){ model in
                    MyDynamicRow(model: model).environmentObject(myDynamicModel).id(model.id)
                }
            }.introspectTabBarController(customize: { UITabBarController in
                UITabBarController.tabBar.isHidden = true
            }).modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "我的动态圈")).modifier(LoadingView(isShowing: $myDynamicModel.showLoading, bgColor: $myDynamicModel.loadingBgColor)).toast(isShow: $myDynamicModel.showToast, msg: myDynamicModel.toastMsg)
            if myDynamicModel.showCommentList {
                CommentListView(show: $myDynamicModel.showCommentList).environmentObject(myDynamicModel.showCommentCircleModel)
            }
        }

    }
}

struct MyDynamicRow:View{
    @EnvironmentObject var myDynamicModel : MyDynamicModel
    var model : CircleModel
    @State var images: [String] = []
    @State var imageSize : CGSize = CGSize(width: 100, height: 100)
    @State var rowsCount : Int = 0
    @State var likeCircleMap : [Int:CircleLikeUserInfo] = [:]
    @State var isDeleteCircle : Bool = false
    var body: some View{
        VStack{
            HStack(alignment: .center, spacing: 10){
                let strs = getCreateAtStr()
                VStack(alignment: .leading, spacing: 0){
                    Text(strs[0]).font(.system(size: 14,weight:.medium)).foregroundColor(.black)
                    Text(strs[1]).font(.system(size: 13)).foregroundColor(.colorWithHexString(hex: "#999999"))
                }.frame(width:40).padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0)).background(RoundedRectangle(cornerRadius: 5).fill(Color.colorWithHexString(hex: "#F3F3F3")))
               
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
            
            HStack(alignment:.center,spacing:0){
                Spacer().frame(width:65)
                HStack(alignment: .center, spacing: 5) {
                    let date = model.createAt.stringToDate(format: "yyyy-MM-dd HH:mm:ss")
                    let dateStr = date?.stringFormat(format: "yyyy年M月dd日 HH:mm") ?? ""
                    Text(dateStr).font(.system(size: 13)).foregroundColor(.colorWithHexString(hex: "#999999"))
                    Text("删除").font(.system(size: 13)).foregroundColor(.blue).onTapGesture {
                       isDeleteCircle = true
                    }.alert(isPresented: $isDeleteCircle) {
                        Alert(title: Text("删除该动态？"), message: nil,
                            primaryButton: .default(
                                Text("取消"),
                                action: {
                                    
                                }
                            ),
                            secondaryButton: .destructive(
                                Text("删除"),
                                action: {
                                    myDynamicModel.requestDeleteCircle(circleId: model.id)
                                }
                            ))
                    }
                }
                Spacer()
                HStack(alignment: .center, spacing: 8) {
                    Image("like").renderingMode(.template).resizable().aspectRatio(contentMode: .fill).frame(width: 24, height: 24, alignment: .center).foregroundColor( likeCircleMap[UserCenter.shared.userInfoModel?.id ?? 0] != nil ? Color.red : Color.gray)
                    Text("\(model.likeCount)").foregroundColor(.colorWithHexString(hex: "#999999"))
                }.onTapGesture {
                    let item = likeCircleMap[UserCenter.shared.userInfoModel?.id ?? 0]
                    myDynamicModel.requestCreateLikeCircle(likeCircle: item != nil ? false : true, model: model) { likeCircle in
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
                    }
                }
                Spacer().frame(width:35)
                HStack(alignment: .center, spacing: 8) {
                    Image("comment").resizable().renderingMode(.template).aspectRatio(contentMode: .fill).frame(width: 24, height: 24, alignment: .center).foregroundColor(Color.gray)
                    Text("\(model.commentCount)").foregroundColor(.colorWithHexString(hex: "#999999"))
                }.onTapGesture {
                    myDynamicModel.showCommentCircleModel = model
                    myDynamicModel.showCommentList = true
                }
                
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
        }.padding(.bottom,20).onAppear {
            if !model.images.isEmpty{
                if model.images.contains(",") {
                    images =  model.images.components(separatedBy: ",")
                }else{
                    images = [model.images]
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
    
    func getCreateAtStr() ->[String]{
        let date = model.createAt.stringToDate(format: "yyyy-MM-dd HH:mm:ss")
        let Month = date?.stringFormat(format: "M") ?? ""
        let Day = date?.stringFormat(format: "d") ?? ""
        let Year = date?.stringFormat(format: "yyyy") ?? ""
        if Int(Year) ?? 0 < Date().year {
            return [String(format: "%@.%@",Month,Day),String(format: "%@", Year)]
        }
        return [String(format: "%@",Day),String(format: "%@月", Month)]
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

struct MyDynamicPage_Previews: PreviewProvider {
    static var previews: some View {
        MyDynamicPage()
    }
}
