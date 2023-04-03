//
//  UserIntroduceView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/25.
//

import SwiftUI

class IntroductionModel : BaseModel{
    @Published  var recommandModel : ReCommandModel = ReCommandModel()
    @Published var meLikeThis : Bool = true
    @Published var showLikeEachOther : Bool = false
    @Published var likeUseAvatar : String = ""
    @Published var likeEachOther : Bool = false
    func requestUserIntroduction(uid:Int){
        let param = ["uid":uid]
        self.showLoading = true
        self.loadingBgColor = .white
        NW.request(urlStr: "get/user/introduction", method: .post, parameters: param) { response in
            self.showLoading = false
            guard let meLike = response.data["meLike"] as? Bool else{
                return
            }
            self.meLikeThis = meLike
            guard let likeEachOther = response.data["likeEachOther"] as? Bool else{
                return
            }
            self.showLikeEachOther = likeEachOther
            guard let dic = response.data["userInfo"] as? [String :Any] else{
                return
            }
            guard let model = ReCommandModel.deserialize(from: dic, designatedPath: nil) else{
                return
            }
            if self.showLikeEachOther {
                self.likeUseAvatar = model.avatar
            }
            self.recommandModel = model
        } failedHandler: { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }
    }
    
    func requestLikePerson(toUserId:Int,like:Bool){
        let param = ["toUserId":toUserId,"like":like] as [String : Any]
        self.showLoading = true
        self.loadingBgColor = .clear
        NW.request(urlStr: "like/person", method: .post, parameters: param) { response in
            self.showLoading = false
            let dic = response.data
            self.meLikeThis = true
            guard let likeUserAvatar = dic["likeUseAvatar"] as? String else{
                self.likeUseAvatar = ""
                return
            }
            self.likeUseAvatar = likeUserAvatar
            if !likeUserAvatar.isEmpty {
                self.showLikeEachOther = true
            }else{
                self.showToast = true
                self.toastMsg = "喜欢成功"
            }
        } failedHandler: { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }
    }
}

struct UserIntroduceView: View {
    var uid : Int
    @StateObject var introductionModel : IntroductionModel = IntroductionModel()
    @State var uiTabarController: UITabBarController?
    @State var isFirst : Bool = true
    @State var likeOther : Bool = true
    var body: some View {
        ZStack(alignment: .bottom){
        RefreshableScrollView(refreshing: .constant(false), pullDown: nil, footerRefreshing: .constant(false), loadMore: .constant(false), onFooterRefreshing: nil){
               
            CardView().environmentObject(introductionModel.recommandModel).id(UUID())
                HomePageAboutUsView(title: "关于我",content: introductionModel.recommandModel.myTag.count > 0 ? (introductionModel.recommandModel.aboutMeDesc + "\n" + introductionModel.recommandModel.myTag) : introductionModel.recommandModel.aboutMeDesc,userPhotos: introductionModel.recommandModel.userPhotos)
                 HomePageAboutUsView(title: "希望对方",content: introductionModel.recommandModel.likePersonTag,userPhotos: [])
                if !introductionModel.recommandModel.loveGoalsDesc.isEmpty {
                    HomePageAboutUsView(title: "恋爱目标",content: introductionModel.recommandModel.loveGoalsDesc,userPhotos: [])
                }
            
              Spacer().frame(height:kSafeBottom+60)
        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).modifier(LoadingView(isShowing: $introductionModel.showLoading, bgColor: $introductionModel.loadingBgColor)).modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: introductionModel.recommandModel.nickName)).onAppear {
            if !isFirst {
                return
            }
            isFirst = false
            introductionModel.requestUserIntroduction(uid: uid)
            
        }.alertB(isPresented: $introductionModel.showLikeEachOther, builder: {
            LikeEachOtherView(isShow: $introductionModel.showLikeEachOther,avatar: UserCenter.shared.userInfoModel?.avatar ?? "",likeUserAvatar: introductionModel.likeUseAvatar,toUserId: uid)
        }).toast(isShow: $introductionModel.showToast, msg: introductionModel.toastMsg)
            if !introductionModel.meLikeThis {
                VStack(alignment: .center, spacing: 0){
                    Image("like_solid")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30, alignment: .center).background(Circle().fill(btnLRLineGradient).frame(width: 50, height: 50, alignment: .leading)).contentShape(Rectangle()).onTapGesture {
                            introductionModel.requestLikePerson(toUserId: uid, like: true)
                        }
                    Spacer().frame(height:kSafeBottom+15)
                }
            }
        }.ignoresSafeArea(edges: .bottom)
    }
    
   
    
    

    
    
}

//struct UserIntroduceView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserIntroduceView()
//    }
//}
