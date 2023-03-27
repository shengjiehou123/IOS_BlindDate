//
//  UserIntroduceView.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/25.
//

import SwiftUI

class IntroductionModel : ObservableObject{
    @Published  var recommandModel : ReCommandModel = ReCommandModel()
    @Published  var  computedModel : MyComputedProperty = MyComputedProperty()
    func requestUserIntroduction(uid:Int){
        let param = ["uid":uid]
        computedModel.showLoading = true
        computedModel.loadingBgColor = .white
        NW.request(urlStr: "get/user/introduction", method: .post, parameters: param) { response in
            self.computedModel.showLoading = false
            guard let dic = response.data["userInfo"] as? [String :Any] else{
                return
            }
            guard let model = ReCommandModel.deserialize(from: dic, designatedPath: nil) else{
                return
            }
            self.recommandModel = model
        } failedHandler: { response in
            self.computedModel.showLoading = false
            self.computedModel.showToast = true
            self.computedModel.toastMsg = response.message
        }

    }
}

struct UserIntroduceView: View {
    var uid : Int
    @StateObject var introductionModel : IntroductionModel = IntroductionModel()
    @State var uiTabarController: UITabBarController?
    @State var isFirst : Bool = true
    var body: some View {
        ZStack(alignment: .bottom){
        RefreshableScrollView(refreshing: .constant(false), pullDown: nil, footerRefreshing: .constant(false), loadMore: .constant(false), onFooterRefreshing: nil){
               
            CardView().environmentObject(introductionModel.recommandModel).id(UUID())
                HomePageAboutUsView(title: "关于我",content: introductionModel.recommandModel.myTag.count > 0 ? (introductionModel.recommandModel.aboutMeDesc + "\n" + introductionModel.recommandModel.myTag) : introductionModel.recommandModel.aboutMeDesc,userPhotos: introductionModel.recommandModel.userPhotos)
                 HomePageAboutUsView(title: "希望对方",content: introductionModel.recommandModel.likePersonTag,userPhotos: [])
                if !introductionModel.recommandModel.loveGoalsDesc.isEmpty {
                    HomePageAboutUsView(title: "恋爱目标",content: introductionModel.recommandModel.loveGoalsDesc,userPhotos: [])
                }
            
              Spacer().frame(height:kSafeBottom+55)
        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).modifier(LoadingView(isShowing: $introductionModel.computedModel.showLoading, bgColor: $introductionModel.computedModel.loadingBgColor)).modifier(NavigationViewModifer(hiddenNavigation: .constant(false), title: introductionModel.recommandModel.nickName)).onAppear {
            if !isFirst {
                return
            }
            isFirst = false
            introductionModel.requestUserIntroduction(uid: uid)
            
        }.toast(isShow: $introductionModel.computedModel.showToast, msg: introductionModel.computedModel.toastMsg).introspectTabBarController { UITabBarController in
            UITabBarController.tabBar.isHidden = true
            uiTabarController = UITabBarController
//            uiTabarController  = UITabBarController
        }
            VStack(alignment: .center, spacing: 0){
                Image("like_solid")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30, alignment: .center).background(Circle().fill(Color.red).frame(width: 50, height: 50, alignment: .leading)).contentShape(Rectangle()).onTapGesture {
                        requestLikePerson(toUserId: uid, like: true)
                    }
                Spacer().frame(height:kSafeBottom)
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
    
    func requestLikePerson(toUserId:Int,like:Bool){
        let param = ["toUserId":toUserId,"like":like] as [String : Any]
        NW.request(urlStr: "like/person", method: .post, parameters: param) { response in
//            let dic = response.data
            let compu = MyComputedProperty()
            compu.showToast = true
            compu.toastMsg = "喜欢成功"
            self.introductionModel.computedModel = compu
//            self.introductionModel.computedModel.toastMsg = "喜欢成功"
//            guard let likeUserAvatar = dic["likeUseAvatar"] as? String else{
//                return
//            }
//            if !likeUserAvatar.isEmpty {
//
//            }else{
//
//            }
        } failedHandler: { _ in
        
        }
    }

    
    
}

//struct UserIntroduceView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserIntroduceView()
//    }
//}
