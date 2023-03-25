//
//  MyDynamicPage.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/25.
//

import SwiftUI
import SDWebImageSwiftUI
import JFHeroBrowser

class MyDynamicModel:ObservableObject{
    @Published var page : Int = 1
    let pageLimit : Int = 10
    @Published var listData:[CircleModel] = []
    @Published var computedModel : MyComputedProperty = MyComputedProperty()
    
    init(){
        requestCircleList(state: .normal)
    }
    
    func requestCircleList(state:RefreshState){
        if state == .normal {
            computedModel.loadingBgColor = .white
            computedModel.showLoading = true
            page = 1
        }else if state == .pullDown{
            page = 1
        }else if state == .pullUp{
            page += 1
        }
        let params = ["page":page,"pageLimit":pageLimit]
        NW.request(urlStr: "get/my/circle", method: .post, parameters: params) { response in
            self.computedModel.showLoading = false
            self.computedModel.pullDown = false
            self.computedModel.footerRefreshing = false
            guard let list = response.data["list"] as? [[String:Any]] else{
                return
            }
            if state == .normal || state == .pullDown {
                self.listData.removeAll()
            }
            if list.count < self.pageLimit {
                self.computedModel.loadMore = false
            }else{
                self.computedModel.loadMore = true
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
            self.computedModel.pullDown = false
            self.computedModel.footerRefreshing = false
            self.computedModel.loadMore = true
        }

    }
    
    func requestCreateLikeCircle(likeCircle:Bool,model:CircleModel, requestHandleCompletion:@escaping (_ likeCircle:Bool) -> Void){
        let params = ["circleId":model.id,"uid":model.uid,"likeCircleUid":UserCenter.shared.userInfoModel?.id ?? 0,"likeCircle":likeCircle] as [String : Any]
        
        NW.request(urlStr: "like/circle", method: .post, parameters: params) { response in
           requestHandleCompletion(likeCircle)
        } failedHandler: { response in
            
        }
    }
}

struct MyDynamicPage: View {
    @StateObject var myDynamicModel : MyDynamicModel = MyDynamicModel()
    var body: some View {
        RefreshableScrollView(refreshing: $myDynamicModel.computedModel.pullDown, pullDown: {
            myDynamicModel.requestCircleList(state: .pullDown)
        }, footerRefreshing: $myDynamicModel.computedModel.footerRefreshing, loadMore: $myDynamicModel.computedModel.loadMore) {
            myDynamicModel.requestCircleList(state: .pullUp)
        } content: {
            ForEach(myDynamicModel.listData,id:\.id){ model in
                MyDynamicRow(model: model).environmentObject(myDynamicModel)
            }
        }.modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: "我的动态圈")).introspectTabBarController { UITabBarController in
            UITabBarController.tabBar.isHidden = true
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
    var body: some View{
        VStack{
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
                Spacer()
                HStack(alignment: .center, spacing: 8) {
                    Image("like").renderingMode(.template).resizable().aspectRatio(contentMode: .fill).frame(width: 24, height: 24, alignment: .center).foregroundColor( likeCircleMap[UserCenter.shared.userInfoModel?.id ?? 0] != nil ? Color.red : Color.gray)
                    Text("\(model.likeCount)").foregroundColor(.colorWithHexString(hex: "#999999"))
                }.onTapGesture {
                    let item = likeCircleMap[UserCenter.shared.userInfoModel?.id ?? 0]
                    myDynamicModel.requestCreateLikeCircle(likeCircle: item != nil, model: model) { likeCircle in
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
                HStack(alignment: .center, spacing: 8) {
                    Image("comment").resizable().renderingMode(.template).aspectRatio(contentMode: .fill).frame(width: 24, height: 24, alignment: .center).foregroundColor(Color.gray)
                    Text("\(model.commentCount)").foregroundColor(.colorWithHexString(hex: "#999999"))
                }.onTapGesture {
                    
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
